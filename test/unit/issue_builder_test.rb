require File.expand_path('../../test_helper', __FILE__)

class HhIssueBuilderTest < ActiveSupport::TestCase
  fixtures :issues, :projects, :trackers, :issue_statuses

  context 'execute' do

    setup do
      @user = User.new(login: 'redmine_hire', firstname: 'Name', lastname: 'Lastname')
      @user.validate
      @user.email_address.address = 'test@mail.ru'
      @user.save!

      vacancy = HhVacancy.create!(name: 'Test', city: 'Москва', link: 'https://google.com')
      @hh_response = HhResponse.create!(hh_vacancy_id: vacancy.id, resume: {}, cover_letter: "Готов работать удаленно")

      Setting.stubs(:plugin_redmine_hire).returns(
        'project_name' => 'Работа',
        'issue_status' => 'Новая',
        'issue_tracker' => 'Основной',
        'issue_author' => @user.id
      )
    end

    subject { Hh::IssueBuilder.new(@hh_response).execute }

    # context 'when Helpdesk present' do

    #   setup do
    #     Hh::IssueBuilder.any_instance.stubs(:helpdesk_present?).returns(true)
    #   end

    #   should 'assign issue attributes' do
    #     subject
    #     issue = Issue.last
    #     status = IssueStatus.find(1)

    #     assert_equal @params[:vacancy_id].to_i, issue.vacancy_id
    #     assert_equal @params[:resume_id], issue.resume_id
    #     assert_equal status.id, issue.status_id
    #     assert_equal @user.id, issue.author_id
    #     assert_equal @params[:hh_response_id].to_i, issue.hh_response_id
    #   end

    # end

    context 'when Helpdesk not present' do

      setup do
        Hh::IssueBuilder.any_instance.stubs(:helpdesk_present?).returns(false)
      end

      should 'assign issue attributes' do
        subject
        issue = Issue.last
        status = IssueStatus.find(1)

        assert_equal status.id, issue.status_id
        assert_equal @user.id, issue.author_id
        assert_equal @hh_response.reload.issue_id, issue.id
      end
    end
  end
end
