class AddCalendarTokenToFamilies < ActiveRecord::Migration[8.1]
  def change
    add_column :families, :calendar_token, :string

    reversible do |direction|
      direction.up { execute "UPDATE families SET calendar_token = replace(gen_random_uuid()::text, '-', '')" }
    end

    change_column_null :families, :calendar_token, false
    add_index :families, :calendar_token, unique: true
  end
end
