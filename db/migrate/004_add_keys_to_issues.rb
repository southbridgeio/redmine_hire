class AddKeysToIssues < ActiveRecord::Migration
  def up
    add_column :issues, :vacancy_id, :bigint
    add_column :issues, :resume_id, :string
    add_index :issues, :vacancy_id
    add_index :issues, :resume_id
  end

  def down
    remove_index :issues, column: :vacancy_id
    remove_index :issues, column: :resume_id
    remove_column :issues, :vacancy_id
    remove_column :issues, :resume_id
  end
end
