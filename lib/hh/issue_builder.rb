require 'net/http'
require 'uri'

module Hh
  class IssueBuilder
    attr_reader :hh_response

    def initialize(hh_response)
      @hh_response = hh_response
    end

    def execute
      return if hh_response.issue_id
      new_issue_status = IssueStatus.find_or_create_by!(name: issue_status_name)
      new_issue_author = User.find_by(id: issue_author) || User.find_by(status: User::STATUS_ANONYMOUS)

      Issue.transaction do
        issue = Issue.create!(
          priority: IssuePriority.find_by!(position_name: 'default'),
          project_id: Project.find_or_create_by!(name: project_name).id,
          subject: build_subject,
          tracker_id: Tracker.find_or_create_by!(name: issue_tracker_name).id,
          status_id: new_issue_status.id,
          author_id: new_issue_author.id
        )

        hh_response.update!(issue_id: issue.id)

        if helpdesk_present?
          contact = Contact.find_or_initialize_by(email: hh_response.applicant_email)
          contact.assign_attributes(
            project: issue.project,
            first_name: hh_response.applicant_first_name,
            last_name: hh_response.applicant_last_name
          )
          contact.save!

          HelpdeskTicket.create!(
            from_address: hh_response.applicant_email,
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

    def build_subject
      "#{hh_response.vacancy_name} #{hh_response.applicant_city ? "(#{hh_response.applicant_city})" : nil}"
    end

    def helpdesk_present?
      helpdesk = Redmine::Plugin.find(:redmine_contacts_helpdesk) rescue nil
      helpdesk.present?
    end
  end
end
