class CreateHhApplicants < ActiveRecord::Migration
  def change
    create_table :hh_applicants do |t|
      t.string :hh_id, index: true
      t.text :resume
      t.datetime :resume_updated_at
    end
  end
end
