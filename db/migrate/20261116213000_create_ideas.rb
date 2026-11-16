class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.references :entry, null: false, foreign_key: true
      t.text :description, null: false

      t.timestamps
    end
  end
end
