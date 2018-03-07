class RefusalWorker
  include Hh::Worker

  def perform(issue_id, refusal_url)
    issue = Issue.find(issue_id)
    hh_response = HhResponse.find_by(hh_id: issue.hh_response_id)

    response = Hh::ApiService.new.api_post(refusal_url)
    if response.code.start_with?('2')
      issue.refusal!
      issue.journals.create!(user_id: issue.author_id, notes: 'Отказ отправлен!')
    else
      hh_response.update!(refusal_url: nil)
      issue.journals.create!(user_id: issue.author_id, notes: 'Отказ не отправлен, ссылка для отказа не активна')
    end
  end
end
