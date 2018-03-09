require 'net/http'
require 'uri'

module Hh
  class IssueBuilder
    attr_reader :api_data

    def initialize(api_data)
      @api_data = api_data
    end

    def execute
      return if Issue.where(vacancy_id: api_data[:vacancy_id], resume_id: api_data[:resume_id]).present?
      new_issue_status = IssueStatus.find_or_create_by!(name: issue_status_name)
      new_issue_author = User.find_by(id: issue_author) || User.find_by(status: User::STATUS_ANONYMOUS)
      if helpdesk_present?
        response = helpdesk_api_post
        raise "Helpdesk API Error" unless response.code.start_with?('2')
        new_issue_id = response.body.gsub(/[^\d]/, '')
      else
        response = redmine_api_post
        raise "Redmine API Error" unless response.code.start_with?('2')
        new_issue_id = JSON.parse(response.body)['issue']['id']
      end
      Issue.find(new_issue_id).update!(
        vacancy_id: api_data[:vacancy_id],
        resume_id: api_data[:resume_id],
        status_id: new_issue_status&.id,
        author_id: new_issue_author&.id,
        hh_response_id: api_data[:hh_response_id]
      )
    end

    private

    def project_name
      Setting.plugin_redmine_hire['project_name']
    end

    def issue_status_name
      Setting.plugin_redmine_hire['issue_status']
    end

    def issue_tracker_name
      Setting.plugin_redmine_hire['issue_tracker']
    end

    def issue_author
      Setting.plugin_redmine_hire['issue_author']
    end

    def helpdesk_api_post
      uri = URI.parse "#{Setting['protocol']}://#{Setting['host_name']}/helpdesk/create_ticket.xml"
      request = Net::HTTP::Post.new uri.path
      request.content_type = 'application/xml'
      request['X-Redmine-API-Key'] = REDMINE_API_KEY
      request.body = build_xml

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if Setting['protocol'] == "https"
      response = http.request(request)
    end

    def build_xml
      xm = Builder::XmlMarkup.new
      xm.instruct!
      xm.ticket {
        xm.issue {
          xm.project_id(Project.find_or_create_by!(name: project_name).id)
          xm.subject(build_subject)
          xm.tracker_id(Tracker.find_or_create_by!(name: issue_tracker_name).id)
          xm.description(build_comment)
        }
        xm.contact {
          xm.email(api_data[:applicant_email])
          xm.first_name(api_data[:applicant_first_name])
          xm.last_name(api_data[:applicant_last_name])
        }
      }
    end

    def redmine_api_post
      uri = URI.parse "#{Setting['protocol']}://#{Setting['host_name']}/issues.json"
      request = Net::HTTP::Post.new uri.path
      request.content_type = 'application/json'
      request['X-Redmine-API-Key'] = REDMINE_API_KEY
      request.body = {
        issue: {
          project_id: Project.find_or_create_by!(name: project_name).id,
          subject: build_subject,
          tracker_id: Tracker.find_or_create_by!(name: issue_tracker_name).id,
          description: build_comment,
        }
      }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if Setting['protocol'] == "https"
      response = http.request(request)
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

    def helpdesk_present?
      helpdesk = Redmine::Plugin.find(:redmine_contacts_helpdesk) rescue nil
      helpdesk.present?
    end

  end
end
