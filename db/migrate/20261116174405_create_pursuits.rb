class CreatePursuits < ActiveRecord::Migration[8.1]
  def change
    create_table :pursuits do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name, null: false
      t.text :notes
      t.date :started_on, null: false
      t.date :finished_on

      t.timestamps
    end
  end
end
