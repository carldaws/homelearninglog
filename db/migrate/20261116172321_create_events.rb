class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :family, null: false, foreign_key: true
      t.references :grown_up, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.date :starts_on, null: false
      t.time :start_time
      t.time :end_time
      t.integer :repeats, null: false, default: 0
      t.date :repeats_until
      t.text :notes

      t.timestamps
    end
  end
end
