class CreateCancellations < ActiveRecord::Migration[8.1]
  def change
    create_table :cancellations do |t|
      t.references :event, null: false, foreign_key: true, index: false
      t.date :cancelled_on, null: false

      t.timestamps
    end

    add_index :cancellations, %i[ event_id cancelled_on ], unique: true
  end
end
