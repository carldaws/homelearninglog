class CreateAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :accesses do |t|
      t.references :child, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true
      t.string :calendar_token, null: false, index: { unique: true }

      t.timestamps
    end

    add_index :accesses, %i[ child_id user_id ], unique: true
  end
end
