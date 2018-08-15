module RedmineHireHelper
  include ActionView::Helpers::DateHelper

  def experience_formatted(start_at, end_at)
    end_at = end_at || Date.today
    distance_of_time_in_words(start_at.to_date, end_at.to_date)
  end
end
