require 'net/http'
require 'uri'

module Hh
  class IssueBuilder

    PROJECT_NAME = Setting.plugin_redmine_hire['project_name']
    ISSUE_STATUS = Setting.plugin_redmine_hire['issue_status']
    ISSUE_TRACKER = Setting.plugin_redmine_hire['issue_tracker']
    ISSUE_AUTOR = Setting.plugin_redmine_hire['issue_autor']
    REDMINE_API_KEY = Setting.plugin_redmine_hire['redmine_api_key']

    attr_reader :api_data

    def initialize(api_data)
      @api_data = api_data
    end

    def execute
      return if Issue.where(vacancy_id: api_data[:vacancy_id], resume_id: api_data[:resume_id]).present?
      uri = URI.parse "#{Setting['protocol']}://#{Setting['host_name']}/helpdesk/create_ticket.xml"
      request = Net::HTTP::Post.new uri.path
      request.content_type = 'application/xml'
      request['X-Redmine-API-Key'] = REDMINE_API_KEY
      request.body = build_xml

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if Setting['protocol'] == "https"
      response = http.request(request)

      raise "Helpdesk API Error" if (response.code.start_with?('5') || response.code.start_with?('4'))

      new_issue_id = response.body.gsub(/[^\d]/, '')
      new_issue_status_id = IssueStatus.find_by(name: ISSUE_STATUS).id
      new_issue_author_id = User.find_by(login: ISSUE_AUTOR).id
      Issue.find(new_issue_id).update!(
        vacancy_id: api_data[:vacancy_id],
        resume_id: api_data[:resume_id],
        status_id: new_issue_status_id,
        author_id: new_issue_author_id,
        hh_response_id: api_data[:hh_response_id]
      )

      # create issues without Helpdesk API

      #project = Project.find_or_create_by!(name: PROJECT_NAME)
      #issue = project.issues.find_or_create_by!(vacancy_id: api_data[:vacancy_id], resume_id: api_data[:resume_id]) do |i|
      #  i.subject = build_subject
      #  i.status = IssueStatus.find_by(name: ISSUE_STATUS)
      #  i.tracker = Tracker.find_by(name: ISSUE_TRACKER)
      #  i.author = User.find_by(login: ISSUE_AUTOR)
      #  i.description = build_comment
      #end
    end

    private

    def build_xml
      xm = Builder::XmlMarkup.new
      xm.instruct!
      xm.ticket {
        xm.issue {
          xm.project_id(Project.find_by(name: PROJECT_NAME).id)
          xm.subject(build_subject)
          xm.tracker_id(Tracker.find_by(name: ISSUE_TRACKER).id)
          xm.description(build_comment)
        }
        xm.contact {
          xm.email(api_data[:applicant_email])
          xm.first_name(api_data[:applicant_first_name])
          xm.last_name(api_data[:applicant_last_name])
        }
      }
    end

    def build_comment
      previous_issues_ids = Issue.where(resume_id: api_data[:resume_id]).pluck(:id)

      controller = ActionController::Base.new
      view = ActionView::Base.new('plugins/redmine_hire/app/views', {}, controller)
      view.class_eval do
        include RedmineHireHelper
      end

      view.render(
        template: 'issues/issue_comment',
        layout: false,
        content_type: 'text/plain',
        locals: { api_data: api_data, previous_issues_ids: previous_issues_ids }
      )
    end

    def build_subject
      "#{api_data[:vacancy_name]} #{api_data[:applicant_city].present? ? '('+api_data[:applicant_city]+')' : nil}"
    end

    def logger
      @logger ||= Logger.new(Rails.root.join('log', 'redmine_hire.log'))
    end

  end
end
