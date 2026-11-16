class CreateJoinTablesForPursuits < ActiveRecord::Migration[8.1]
  def change
    create_join_table :children, :pursuits do |t|
      t.index %i[ pursuit_id child_id ], unique: true
      t.index :child_id
    end
    add_foreign_key :children_pursuits, :children
    add_foreign_key :children_pursuits, :pursuits

    create_join_table :entries, :pursuits do |t|
      t.index %i[ pursuit_id entry_id ], unique: true
      t.index :entry_id
    end
    add_foreign_key :entries_pursuits, :entries
    add_foreign_key :entries_pursuits, :pursuits

    create_join_table :activities, :pursuits do |t|
      t.index %i[ pursuit_id activity_id ], unique: true
      t.index :activity_id
    end
    add_foreign_key :activities_pursuits, :activities
    add_foreign_key :activities_pursuits, :pursuits
  end
end
