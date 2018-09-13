class HhVacancy < ActiveRecord::Base
  serialize :info

  has_many :hh_responses
end
