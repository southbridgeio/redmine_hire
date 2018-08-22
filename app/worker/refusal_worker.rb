class RefusalWorker
  include Hh::Worker

  def initialize(api = Hh::ApiService.new)
    @api = api
  end

  def perform(issue_id, refusal_url)
    issue = Issue.find(issue_id)
    hh_response = HhResponse.find_by(hh_id: issue.hh_response_id)

    refusal_template = api.api_get(refusal_url)
    refusal_text = refusal_template.dig('mail', 'text')

    api.api_put("#{Hh::ApiService::BASE_URL}/negotiations/discard_by_employer/#{hh_response.hh_id}", message: refusal_text)
    issue.refusal!
    issue.journals.create!(user_id: issue.author_id, notes: 'Отказ отправлен!')
  end

  private

  attr_reader :api
end
