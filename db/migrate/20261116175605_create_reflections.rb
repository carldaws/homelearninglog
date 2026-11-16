class CreateReflections < ActiveRecord::Migration[8.1]
  def change
    create_table :reflections do |t|
      t.references :family, null: false, foreign_key: true, index: false
      t.date :week_of, null: false
      t.text :notes

      t.timestamps
    end

    add_index :reflections, %i[ family_id week_of ], unique: true
  end
end
