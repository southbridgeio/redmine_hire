class CreateHhVacancies < ActiveRecord::Migration
  def change
    create_table :hh_vacancies do |t|
      t.bigint :hh_id, index: true
      t.json :info
      t.datetime :info_updated_at
    end

  end
end
