class HhApi

  def initialize
  end

  # GET /employers/{employer_id}/vacancies/active
  def get_active_vacancies_ids
    # do request, get response
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
