module Hh
  class IssueBuilder

    PROJECT_NAME = Setting.plugin_redmine_hire['project_name']
    ISSUE_STATUS = Setting.plugin_redmine_hire['issue_status']
    ISSUE_TRACKER = Setting.plugin_redmine_hire['issue_tracker']
    ISSUE_AUTOR = Setting.plugin_redmine_hire['issue_autor']

    attr_reader :api_data

    def initialize(api_data)
      @api_data = api_data
    end

    def execute
      project = Project.find_or_create_by!(name: PROJECT_NAME)
      issue = project.issues.find_or_create_by!(vacancy_id: api_data[:vacancy_id], resume_id: api_data[:resume_id]) do |i|
        i.subject = build_subject
        i.status = IssueStatus.find_by(name: ISSUE_STATUS)
        i.tracker = Tracker.find_by(name: ISSUE_TRACKER)
        i.author = User.find_by(login: ISSUE_AUTOR)
        i.description = build_comment
      end
    end

    private

    def build_comment
      <<~END
        *Вакансия:* #{api_data[:vacancy_link]} (#{api_data[:vacancy_city]})
        *Имя:* #{api_data[:applicant_first_name]} #{api_data[:applicant_last_name]}
        *Город:* #{api_data[:applicant_city]}
        *Дата рождения:* #{api_data[:applicant_birth_date]&.to_date&.strftime('%d.%m.%Y')}
        *Резюме:* #{api_data[:resume_link]}
        *Фото:* #{api_data[:applicant_photo]}
        *Зарплата:* #{api_data[:salary] || 'не указана'}
        *E-mail:* #{api_data[:applicant_email]}

        *О себе:*
        #{api_data[:description]}

        *Сопроводительное письмо:*
        #{api_data[:cover_letter]}

        *Предыдущие места работы:*
        #{previous_works(api_data[:experience])}

        *Предыдущие отклики:*
        #{previous_issues}
      END
    end

    def build_subject
      "#{api_data[:vacancy_name]} #{api_data[:applicant_city].present? ? '('+api_data[:applicant_city]+')' : nil}"
    end

    def previous_works(works)
      works.map do |work|
        <<~END
          *Период:* #{work['start'].to_date.strftime('%d.%m.%Y')} - #{work['end']&.to_date&.strftime('%d.%m.%Y') || 'наст. время'} (#{exp_in_monthes(work['start'], work['end'])} мес.)
          *Город:* #{work['area']['name'] if work['area'].present?}
          *Компания:* #{work['company']}
          *Опыт:*
          #{work['description']}
        END
      end.join("\n")
    end

    def previous_issues
      previous_issues_ids = Issue.where(resume_id: api_data[:resume_id]).pluck(:id)
      previous_issues_ids.map do |issue_id|
        "##{issue_id}"
      end.join(' ')
    end

    def exp_in_monthes(start, finish)
      finish = finish || Date.current
      (finish.to_date - start.to_date).to_i/30
    end

  end
end
