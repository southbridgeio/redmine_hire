module Hh
  class IssueDecorator < SimpleDelegator
    delegate :vacancy_name,
             :vacancy_city,
             :vacancy_link,
             :applicant_first_name,
             :applicant_last_name,
             to: :hh_response, allow_nil: true

    def cover_letter
      letter = hh_response.cover_letter

      "<notextile>#{letter}</notextile>"
    end
  end
end
