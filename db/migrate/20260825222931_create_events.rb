class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :external_id, null: false
      t.string :title, null: false
      t.text :description
      t.datetime :starts_at, null: false
      t.string :image_url

      t.timestamps
    end

    add_index :events, :external_id, unique: true
  end
end
