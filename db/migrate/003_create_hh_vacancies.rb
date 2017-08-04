class CreateHhVacancies < ActiveRecord::Migration
  def change
    create_table :hh_vacancies do |t|
      t.string :hh_id, index: true
      t.jsonb :info
      t.datetime :info_updated_at
    end

  end
end
