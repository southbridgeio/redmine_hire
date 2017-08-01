require 'net/http'
require "uri"

class HhApi

  ACCESS_TOKEN = 'OH8I8E971RUO873RODIF7K62RPQHTPVMRJTJFITB3IH280UCHARB42ALSJV5US6Q'
  EMPLOYER_ID = '1193714'
  USER_AGENT = 'Redmine/redmine_hire_plugin'
  BASE_URL = 'https://api.hh.ru'


  def initialize
  end

  # GET /employers/{employer_id}/vacancies/active
  def get_active_vacancies_ids
    #byebug
    api_response = api_get("#{BASE_URL}/employers/#{EMPLOYER_ID}/vacancies/active")
    vacancies_ids = api_response['items'].map { |item| item['id'] } # ["21823752", "21832250", "21832252", "21886603", "21955892", "21470306", "21996340", "22066538", "21520789", "21530976", "22146965", "22146966"]
  end

  # GET /negotiations?vacancy_id={vacancy_id}
  #def get_response_collections(vacancies_ids)
  #  vacancies_ids.each do |vacancy_id|
  #    # do request, get response
  #  end
  #end

  # GET /negotiations/response?vacancy_id={vacancy_id}
  def get_vacancy_responses(vacancy_id)
    api_response = api_get("#{BASE_URL}/negotiations/response?vacancy_id=#{vacancy_id}")
    api_response['items'].each do |item|
      HhResponse.find_or_create_by!(hh_id: item['id'])
    end
  end

  private

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
