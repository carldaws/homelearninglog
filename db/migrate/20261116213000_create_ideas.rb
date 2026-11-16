class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.references :entry, null: false, foreign_key: true
      t.text :description, null: false
      t.datetime :set_aside_at

      t.timestamps
    end

    add_reference :entries, :followed_idea, foreign_key: { to_table: :ideas }
  end
end
