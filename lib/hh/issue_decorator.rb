module Hh
  class IssueDecorator < SimpleDelegator
    include ActionView::Helpers::DateHelper

    delegate :vacancy_name,
             :vacancy_city,
             :vacancy_link,
             :applicant_first_name,
             :applicant_last_name,
             :applicant_city,
             :applicant_birth_date,
             :applicant_email,
             :resume_link,
             :salary,
             :skills,
             :cover_letter,
             :experience,
             to: :hh_response, allow_nil: true

    def experience_formatted(start_at, end_at)
      end_at = end_at || Date.today
      distance_of_time_in_words(start_at.to_date, end_at.to_date)
    end
  end
end
