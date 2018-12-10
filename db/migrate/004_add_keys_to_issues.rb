class AddKeysToIssues < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    add_column :issues, :vacancy_id, :bigint
    add_column :issues, :resume_id, :string
    add_column :issues, :hh_response_id, :bigint
    add_column :issues, :hiring_status, :integer, default: 0

    add_index :issues, :vacancy_id
    add_index :issues, :resume_id
    add_index :issues, :hh_response_id
  end

  def down
    remove_index :issues, column: :vacancy_id
    remove_index :issues, column: :resume_id
    remove_index :issues, column: :hh_response_id

    remove_column :issues, :vacancy_id
    remove_column :issues, :resume_id
    remove_column :issues, :hh_response_id
    remove_column :issues, :hiring_status
  end
end
