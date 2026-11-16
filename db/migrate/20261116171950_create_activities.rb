class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name, null: false
      t.text :notes
      t.integer :minutes

      t.timestamps
    end
  end
end
