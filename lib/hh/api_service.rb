require 'net/http'
require 'uri'

module Hh
  class ApiService

    ACCESS_TOKEN = Setting.plugin_redmine_hire['hh_access_token']
    EMPLOYER_ID =  Setting.plugin_redmine_hire['hh_employer_id']
    USER_AGENT = 'Redmine/redmine_hire_plugin'
    BASE_URL = 'https://api.hh.ru'

    def initialize
    end

    def execute
      vacancies = get_active_vacancies
      vacancies.each do |vacancy|
        begin
          vacancy_save(vacancy)

          vacancy_responses = get_vacancy_responses(vacancy['id'])

          vacancy_responses.each do |hh_response|
            next if hh_response_present?(hh_response['id'].to_i)
            hh_response_save(hh_response)

            resume = api_get(hh_response['resume']['url'])
            applicant_save(resume)

            cover_letter = get_cover_letter(hh_response['messages_url'])

            IssueBuilder.new(api_data(vacancy, resume, cover_letter)).execute
          end
        rescue => e
          logger.error e.to_s
          logger.error e.backtrace.join("\n")
          next
        end
      end
    end

    def rollback! # only for debug
      Project.find_by(name: 'Работа').issues.where.not(resume_id: nil).destroy_all
      HhResponse.destroy_all
      HhApplicant.destroy_all
      HhVacancy.destroy_all
    end

    private

    def vacancy_save(vacancy)
      vacancy = HhVacancy.find_or_create_by!(hh_id: vacancy['id'])
      vacancy.update!(info: vacancy, info_updated_at: DateTime.current)
    end

    def hh_response_save(hh_response)
      HhResponse.create!(hh_id: hh_response['id'])
    end

    def applicant_save(resume)
      hh_applicant = HhApplicant.find_or_create_by!(hh_id: resume['id'])
      hh_applicant.update!(resume: resume, resume_updated_at: DateTime.current)
    end

    # GET /employers/{employer_id}/vacancies/active // получаем все активные вакансии
    def get_active_vacancies
      api_response = api_get("#{BASE_URL}/employers/#{EMPLOYER_ID}/vacancies/active")
      return api_response['items']
    end

    # GET /employers/{employer_id}/vacancies/???? // получаем все закрытые вакансии
    def get_close_vacancies
      api_response = api_get("#{BASE_URL}/employers/#{EMPLOYER_ID}/vacancies/????")
      return api_response['items']
    end

    # GET /negotiations?vacancy_id={vacancy_id} // получить все коллекции откликов
    #def get_response_collections(vacancies_ids)
    #  vacancies_ids.each do |vacancy_id|
    #    # do request, get response
    #  end
    #end

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
      HhResponse.find_by(hh_id: id).present?
    end

    def api_data(vacancy, resume, cover_letter)
      {
        vacancy_id: vacancy['id'],
        resume_id: resume['id'],
        vacancy_name: vacancy['name'],
        applicant_city: resume['area']['name'],
        vacancy_city: vacancy['area']['name'],
        vacancy_link: vacancy['alternate_url'],
        applicant_email: resume['contact'].select { |c| c['type']['id'] == 'email' }.first['value'],
        applicant_first_name: resume['first_name'],
        applicant_last_name: resume['last_name'],
        applicant_middle_name: resume['middle_name'],
        applicant_birth_date: resume['birth_date'],
        resume_link: resume['alternate_url'],
        applicant_photo: (resume['photo']['medium'] if resume['photo'].present?),
        salary: (resume['salary']['amount'] if resume['salary'].present?),
        experience: resume['experience'],
        description: resume['skills'],
        cover_letter: cover_letter
      }
    end

    def api_get(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      header = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{ACCESS_TOKEN}",
        "User-Agent" => USER_AGENT
      }
      request = Net::HTTP::Get.new(uri.request_uri, header)
      response = http.request(request)
      JSON.parse(response.body)
    end

    def logger
      @logger ||= Logger.new(Rails.root.join('log', 'redmine_hire.log'))
    end
  end
end
