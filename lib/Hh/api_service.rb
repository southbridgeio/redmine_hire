require 'net/http'
require "uri"

module Hh
  class ApiService

    ACCESS_TOKEN = 'OH8I8E971RUO873RODIF7K62RPQHTPVMRJTJFITB3IH280UCHARB42ALSJV5US6Q'
    EMPLOYER_ID = '1193714'
    USER_AGENT = 'Redmine/redmine_hire_plugin'
    BASE_URL = 'https://api.hh.ru'

    def initialize
    end

    def execute
      byebug
      vacancies = get_active_vacancies
      vacancies.each do |vacancy|
        vacancy_responses = get_vacancy_responses(vacancy['id'])

        vacancy_responses.each do |response|
          next if hh_response_present?(response['id'])
          hh_response = Hh::Response.create!(hh_id: response['id'])
          hh_applicant = Hh::Applicant.find_or_create_by!(email: response['resume']['email']) # нужно получить email
          hh_applicant.create_new_task_or_comment(comment_params(vacancy, response['resume']))
        end

      end
    end

    private

    # GET /employers/{employer_id}/vacancies/active // получаем все активные вакансии
    def get_active_vacancies
      api_response = api_get("#{BASE_URL}/employers/#{EMPLOYER_ID}/vacancies/active")
      return api_response['items']
      # ["21823752", "21832250", "21832252", "21886603", "21955892", "21470306", "21996340", "22066538", "21520789", "21530976", "22146965", "22146966"]
    end

    # GET /negotiations?vacancy_id={vacancy_id}
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

    def hh_response_present?(id)
      Hh::Response.find_by(hh_id: id).present?
    end

    def comment_params(vacancy, resume)

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


  end
end
