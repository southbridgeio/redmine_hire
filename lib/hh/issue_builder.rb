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

      Issue.transaction do
        issue = Issue.create!(
          priority: IssuePriority.find_by!(position_name: 'default'),
          project_id: Project.find_or_create_by!(name: project_name).id,
          subject: build_subject,
          tracker_id: Tracker.find_or_create_by!(name: issue_tracker_name).id,
          description: build_comment,
          vacancy_id: api_data[:vacancy_id],
          resume_id: api_data[:resume_id],
          status_id: new_issue_status.id,
          author_id: new_issue_author.id,
          hh_response_id: api_data[:hh_response_id]
        )

        if helpdesk_present?
          contact = Contact.find_or_initialize_by(email: api_data[:applicant_email])
          contact.assign_attributes(
            project: issue.project,
            first_name: api_data[:applicant_first_name],
            last_name: api_data[:applicant_last_name]
          )
          contact.save!

          HelpdeskTicket.create!(
            from_address: api_data[:applicant_email],
            issue: issue,
            customer: contact
          )
        end
      end
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

    def build_comment
      I18n.locale = Setting['default_language']

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
