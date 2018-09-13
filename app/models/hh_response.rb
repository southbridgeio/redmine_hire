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

  def applicant_city
    resume.dig('area', 'name') if resume
  end

  def applicant_email
    resume['contact'].select { |c| c['type']['id'] == 'email' }.first['value'] if resume
  end

  def applicant_birth_date
    resume['birth_date'] if resume
  end

  def resume_link
    resume['alternate_url'] if resume
  end

  def salary
    resume.dig('salary', 'amount') if resume
  end

  def skills
    resume['skills'] if resume
  end

  def experience
    resume['experience'] if resume
  end
end
