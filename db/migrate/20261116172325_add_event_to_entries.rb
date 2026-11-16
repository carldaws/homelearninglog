class AddEventToEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :entries, :event, foreign_key: true
  end
end
