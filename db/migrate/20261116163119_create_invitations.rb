class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.string :token, null: false, index: { unique: true }

      t.timestamps
    end

    create_join_table :children, :invitations do |t|
      t.index :child_id
      t.index %i[ invitation_id child_id ], unique: true
    end

    add_foreign_key :children_invitations, :children
    add_foreign_key :children_invitations, :invitations
  end
end
