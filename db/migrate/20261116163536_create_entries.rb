class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.references :family, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.date :happened_on, null: false
      t.text :notes
      t.integer :minutes

      t.timestamps
    end

    add_index :entries, %i[ family_id happened_on ]
  end
end
