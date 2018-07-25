class ConvertJsonbToSerializable < ActiveRecord::Migration
  def change
    change_column :hh_applicants, :resume, :text
    change_column :hh_vacancies, :info, :text
  end
end