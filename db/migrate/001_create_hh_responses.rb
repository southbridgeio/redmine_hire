class CreateHhResponses < ActiveRecord::Migration
  def change
    create_table :hh_responses do |t|
      t.bigint :hh_id, index: true
      t.string :refusal_url
    end

  end
end
