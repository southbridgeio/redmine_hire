class FixDbStructure < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  class HhResponse < ActiveRecord::Base; end

  def up
    add_column :hh_responses, :resume, :text
    add_column :hh_responses, :cover_letter, :text
    add_column :hh_responses, :hh_vacancy_id, :integer
    add_column :hh_responses, :issue_id, :integer

    add_column :hh_vacancies, :name, :string
    add_column :hh_vacancies, :city, :string
    add_column :hh_vacancies, :link, :string

    HhResponse.reset_column_information

    Issue.where.not(hh_response_id: nil).find_each do |issue|
      next unless response = HhResponse.find_by(hh_id: issue.hh_response_id)
      vacancy = HhVacancy.find_by(hh_id: issue.vacancy_id)
      applicant = HhApplicant.find_by(hh_id: issue.resume_id)
      response.update_columns(issue_id: issue.id, hh_vacancy_id: vacancy.id, resume: applicant.attributes_before_type_cast['resume'])
      issue.update!(description: '')
    end
  end

  def down
    remove_column :hh_responses, :resume
    remove_column :hh_responses, :cover_letter
    remove_column :hh_responses, :hh_vacancy_id
    remove_column :hh_responses, :issue_id

    remove_column :hh_vacancies, :name
    remove_column :hh_vacancies, :city
    remove_column :hh_vacancies, :link
  end
end