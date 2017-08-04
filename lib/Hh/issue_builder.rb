module Hh
  class IssueBuilder

    PROJECT_NAME = 'Работа'

    def initialize(api_data)
      @api_data = api_data
    end

    def execute
      project = Project.find_by(name: PROJECT_NAME)
      issue = project.issues.find_or_create_by!(vacancy_id: @api_data[:vacancy_id], resume_id: @api_data[:resume_id]) do |issue|
        issue.subject = build_subject(@api_data)
      end
      issue.journals.create!(notes: build_comment(@api_data))
    end

    private

    def build_comment(api_data)
      "Вакансия: #{api_data[:vacancy_city]}, #{api_data[:vacancy_link]}.
       ФИО: #{api_data[:last_name]} #{api_data[:first_name]} #{api_data[:middle_name]}.
       Город: #{api_data[:applicant_city]}. Дата рождения: #{api_data[:applicant_birth_date]}.
       Резюме: #{api_data[:resume_link]}. Фото: #{api_data[:applicant_photo]}.
       Зарплата: #{api_data[:salary]}.

       Предыдущие места работы:
       #{previous_works(api_data[:experience])}.

       Предыдущие отклики:
       #{previous_issues}.
      "
    end

    def build_subject(api_data)
      "#{api_data[:vacancy_title]} (#{api_data[:applicant_city]})"
    end

    def previous_works(works)
      # add logic
    end

    def previous_issues
      # Issue.where(resume_id: @resume_id)
    end

  end
end
