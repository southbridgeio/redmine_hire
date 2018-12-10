class CreateHhResponses < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :hh_responses do |t|
      t.bigint :hh_id, index: true
      t.string :refusal_url
    end
  end
end
