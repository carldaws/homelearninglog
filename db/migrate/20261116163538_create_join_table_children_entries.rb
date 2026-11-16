class CreateJoinTableChildrenEntries < ActiveRecord::Migration[8.1]
  def change
    create_join_table :children, :entries do |t|
      t.index %i[ entry_id child_id ], unique: true
      t.index :child_id
    end

    add_foreign_key :children_entries, :children
    add_foreign_key :children_entries, :entries
  end
end
