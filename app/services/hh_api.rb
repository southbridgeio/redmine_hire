require 'net/http'
require "uri"

class HhApi

  ACCESS_TOKEN = 'OH8I8E971RUO873RODIF7K62RPQHTPVMRJTJFITB3IH280UCHARB42ALSJV5US6Q'
  EMPLOYER_ID = '1193714'
  USER_AGENT = 'Redmine/redmine_hire_plugin'
  BASE_URL = 'https://api.hh.ru/'


  def initialize
  end

  # GET /employers/{employer_id}/vacancies/active
  def get_active_vacancies_ids
    byebug
    response = api_get("#{BASE_URL}employers/#{EMPLOYER_ID}/vacancies/active")
    vacancies_ids = []
    response['items'].each do |item|
      vacancies_ids << item['id']
    end
  end

  # GET /negotiations?vacancy_id={vacancy_id}
  def get_response_collections(vacancies_ids)
    vacancies_ids.each do |vacancy_id|
      # do request, get response
    end
  end

  private

  def api_get(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
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
