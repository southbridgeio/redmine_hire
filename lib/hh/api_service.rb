require 'net/http'
require 'uri'

module Hh
  class ApiService
    class RequestError < StandardError
      attr_reader :code, :errors

      def initialize(code:, errors:)
        @code = code
        @errors = errors
        super("Error code: #{code} #{errors.map { |e| "#{e['type']}: #{e['value']}" }.join("\n")}")
      end
    end

    USER_AGENT = 'Redmine/redmine_hire_plugin'
    BASE_URL = 'https://api.hh.ru'

    def initialize
    end

    def execute(vacancies_status)
      vacancies = send("get_#{vacancies_status}_vacancies")
      vacancies.each do |vacancy|
        begin
          ActiveRecord::Base.transaction do
            saved_vacancy = vacancy_save(vacancy)

            vacancy_responses = get_vacancy_responses(vacancy['id'])

            vacancy_responses.each do |hh_response|
              next if hh_response_present?(hh_response['id'].to_i)

              resume = hh_response['resume'].present? ? api_get(hh_response['resume']['url']) : {}
              cover_letter = get_cover_letter(hh_response['messages_url'])

              saved_response = hh_response_save(hh_response, resume, cover_letter, saved_vacancy)

              IssueBuilder.new(saved_response).execute
            end
          end
        rescue RequestError => e
          logger.error e.to_s
          logger.error e.backtrace.join("\n")
        end
      end
    rescue RequestError => e
      logger.error e.to_s
      logger.error e.backtrace.join("\n")
    end

    def rollback! # for debug process
      Project.find_by(name: Hh::IssueBuilder.new({}).project_name).issues.where.not(resume_id: nil).destroy_all
      HhResponse.destroy_all
      HhApplicant.destroy_all
      HhVacancy.destroy_all
    end

    def send_refusal(issue_id)
      issue = Issue.find(issue_id)
      hh_response = HhResponse.find_by(hh_id: issue&.hh_response_id)
      refusal_url = hh_response&.refusal_url

      return if refusal_url.blank?

      if sidekiq_present?
        RefusalWorker.perform_async(issue_id, refusal_url)
      else
        RefusalWorker.new.perform(issue_id, refusal_url)
      end
    end

    def api_get(url)
      tries ||= 3
      header = {
        content_type: "application/json",
        authorization: "Bearer #{access_token}",
        user_agent: USER_AGENT
      }
      RestClient.get(url, header) do |response, _, _|
        result = JSON.parse(response.body) rescue {}
        raise RequestError.new(code: response.code, errors: result['errors']) unless response.code.in?(200..299)
        result
      end
    rescue RequestError => e
      if e.code == 403 && e.errors.any? { |error| error['type'] == 'oauth' && error['value'] == 'token_expired' } && !(tries -= 1).zero?
        logger.info('Tokens expired. Trying to reissue...')
        Hh::OAuth.reissue_tokens && retry
      end
      raise
    end

    def api_put(url, params = {})
      tries ||= 3
      header = {
          content_type: "application/json",
          authorization: "Bearer #{access_token}",
          user_agent: USER_AGENT
      }
      RestClient.put(url, params, header) do |response, _, _|
        result = JSON.parse(response.body) rescue {}
        raise RequestError.new(code: response.code, errors: result['errors']) unless response.code.in?(200..299)
        result
      end
    rescue RequestError => e
      if e.code == 403 && e.errors.any? { |error| error['type'] == 'oauth' && error['value'] == 'token_expired' } && !(tries -= 1).zero?
        logger.info('Tokens expired. Trying to reissue...')
        Hh::OAuth.reissue_tokens && retry
      end
      raise
    end

    def api_post(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      header = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{access_token}",
        "User-Agent" => USER_AGENT
      }
      request = Net::HTTP::Post.new(uri.request_uri, header)
      http.request(request)
    end

    private

    def access_token
      (Setting.find_by(name: :plugin_redmine_hire)&.value || {})['access_token']
    end

    def employer_id
      (Setting.find_by(name: :plugin_redmine_hire)&.value || {})['hh_employer_id']
    end

    def vacancy_save(vacancy)
      vacancy_record = HhVacancy.find_or_create_by!(hh_id: vacancy['id'])
      vacancy_record.update!(name: vacancy['name'], city: vacancy['area']['name'], link: vacancy['alternate_url'])
      vacancy_record
    end

    def hh_response_save(hh_response, resume, cover_letter, vacancy)
      refusal_url = hh_response['actions']
        &.find { |e| e['name'] == 'Отказ' }&.[]('templates')
        &.find { |e| e['name'] == "Шаблон быстрого отказа на отклик" }&.[]('url') || nil

      HhResponse.create!(hh_id: hh_response['id'],
                         refusal_url: refusal_url,
                         resume: resume,
                         cover_letter: cover_letter,
                         hh_vacancy_id: vacancy.id)
    end

    # GET /employers/{employer_id}/vacancies/active // получаем все активные вакансии
    def get_active_vacancies
      api_response = api_get("#{BASE_URL}/employers/#{employer_id}/vacancies/active")
      return api_response['items']
    end

    # GET /employers/{employer_id}/vacancies/archived // получаем все архивные вакансии
    def get_archived_vacancies
      api_response = api_get("#{BASE_URL}/employers/#{employer_id}/vacancies/archived")
      return api_response['items']
    end

    # GET /negotiations/response?vacancy_id={vacancy_id} // получаем отклики из коллекции 'response'
    def get_vacancy_responses(vacancy_id)
      api_response = api_get("#{BASE_URL}/negotiations/response?vacancy_id=#{vacancy_id}")
      return api_response['items']
    end

    def get_cover_letter(messages_url)
      api_response = api_get(messages_url)
      return api_response['items'].first['text']
    end

    def hh_response_present?(id)
      HhResponse.exists?(hh_id: id)
    end

    def sidekiq_present?
      sidekiq = Sidekiq rescue nil
      sidekiq.present?
    end

    def logger
      out = Rails.env.production? ? Rails.root.join('log', 'redmine_hire.log') : STDOUT
      @logger ||= Logger.new(out)
    end

    # Пока не используем коллекции откликов, т.к. все наши отклики в колекции 'response'.
    # Если будут отклики в других коллекциях, нужно будет последовательно забирать данные
    # со всех коллекций
    #
    # GET /negotiations?vacancy_id={vacancy_id} // получить все коллекции откликов
    # def get_response_collections(vacancies_ids)
    #   vacancies_ids.each do |vacancy_id|
    #     # do request, get response
    #   end
    # end
  end
end
