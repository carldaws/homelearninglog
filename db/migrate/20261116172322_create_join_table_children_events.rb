class CreateJoinTableChildrenEvents < ActiveRecord::Migration[8.1]
  def change
    create_join_table :children, :events do |t|
      t.index %i[ event_id child_id ], unique: true
      t.index :child_id
    end

    add_foreign_key :children_events, :children
    add_foreign_key :children_events, :events
  end
end
