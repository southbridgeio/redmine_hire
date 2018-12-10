class CreateHhApplicants < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :hh_applicants do |t|
      t.string :hh_id, index: true
      t.text :resume
      t.datetime :resume_updated_at
    end
  end
end
