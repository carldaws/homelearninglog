class AddForChildrenToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :for_children, :boolean, null: false, default: false
  end
end
