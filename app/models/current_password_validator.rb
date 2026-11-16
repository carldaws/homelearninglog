class CurrentPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid) unless BCrypt::Password.new(record.password_digest_in_database).is_password?(value.to_s)
  end
end
