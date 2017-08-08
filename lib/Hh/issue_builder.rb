module Hh
  class IssueBuilder

    PROJECT_NAME = Setting.plugin_redmine_hire['project_name'] || 'Работа'

    attr_reader :api_data

    def initialize(api_data)
      @api_data = api_data
    end

    def execute
      project = Project.find_or_create_by!(name: PROJECT_NAME)
      issue = project.issues.find_or_create_by!(vacancy_id: api_data[:vacancy_id], resume_id: api_data[:resume_id]) do |issue|
        issue.subject = build_subject
        issue.status = IssueStatus.find_by(name: 'Новая') # need to clarify
        issue.tracker = Tracker.find_by(name: 'Поддержка') # need to clarify
        issue.author = User.last # need to clarify
      end
      issue.journals.create!(notes: build_comment)
    end

    private

    def build_comment
      "Вакансия: #{api_data[:vacancy_city]}, #{api_data[:vacancy_link]}
       ФИО: #{api_data[:applicant_last_name]} #{api_data[:applicant_first_name]} #{api_data[:applicant_middle_name]}
       Город: #{api_data[:applicant_city]}
       Дата рождения: #{api_data[:applicant_birth_date]}
       Резюме: #{api_data[:resume_link]}
       Фото: #{api_data[:applicant_photo]}
       Зарплата: #{api_data[:salary] || 'не указана'}
       Email: #{api_data[:applicant_email]}
       Предыдущие места работы:
       #{previous_works(api_data[:experience])}
       Предыдущие отклики:
       #{previous_issues}
      "
    end

    def build_subject
      "#{api_data[:vacancy_name]} #{api_data[:applicant_city].present? ? '('+api_data[:applicant_city]+')' : nil}"
    end

    def previous_works(works)
      works.map do |work|
        "период: #{work['start']} - #{work['end'] || 'наст. время'} (#{exp_in_monthes(work['start'], work['end'])} мес.)
         город: #{work['area']['name'] if work['area'].present?}
         компания: #{work['company']}
         опыт: #{work['description']}
        "
      end.join("\n")
    end

    def previous_issues
      Issue.where(resume_id: api_data[:resume_id]).map do |issue|
        Rails.application.routes.url_helpers.issue_path(issue)
      end.join(' ')
    end

    def exp_in_monthes(start, finish)
      finish = finish || Date.current
      (finish.to_date - start.to_date).to_i/30
    end

  end
end
