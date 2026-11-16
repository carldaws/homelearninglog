class CreateFamilies < ActiveRecord::Migration[8.1]
  def change
    create_table :families do |t|
      t.string :name, null: false
      t.string :invitation_code, null: false

      t.timestamps
    end
  end
end
