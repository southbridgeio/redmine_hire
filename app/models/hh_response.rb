class HhResponse < ActiveRecord::Base
  delegate :name, :city, :link, to: :hh_vacancy, prefix: :vacancy, allow_nil: true

  serialize :resume

  belongs_to :issue
  belongs_to :hh_vacancy

  def applicant_first_name
    resume['first_name'] if resume
  end

  def applicant_last_name
    resume['last_name'] if resume
  end
end
