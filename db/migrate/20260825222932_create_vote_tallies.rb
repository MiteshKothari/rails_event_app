class CreateVoteTallies < ActiveRecord::Migration[8.1]
  def change
    create_table :vote_tallies do |t|
      t.references :event, null: false, foreign_key: true, index: { unique: true }
      t.integer :up_count, null: false, default: 0
      t.integer :down_count, null: false, default: 0

      t.timestamps
    end
  end
end
