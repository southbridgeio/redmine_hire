class CreateHhVacancies < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :hh_vacancies do |t|
      t.bigint :hh_id, index: true
      t.text :info
      t.datetime :info_updated_at
    end
  end
end
