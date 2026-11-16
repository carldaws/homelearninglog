class KeepEntriesAndCommentsWhenTheirAuthorLeaves < ActiveRecord::Migration[8.1]
  def change
    change_column_null :entries, :author_id, true
    change_column_null :comments, :author_id, true

    remove_foreign_key :entries, :users, column: :author_id
    add_foreign_key :entries, :users, column: :author_id, on_delete: :nullify

    remove_foreign_key :comments, :users, column: :author_id
    add_foreign_key :comments, :users, column: :author_id, on_delete: :nullify

    remove_foreign_key :events, :users, column: :grown_up_id
    add_foreign_key :events, :users, column: :grown_up_id, on_delete: :nullify
  end
end
