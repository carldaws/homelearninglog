class AddChoosingChildToSessions < ActiveRecord::Migration[8.1]
  def change
    add_reference :sessions, :choosing_child, foreign_key: { to_table: :children, on_delete: :nullify }
  end
end
