class SameFamilyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :outside_the_family) if Array(value).any? { it.family_id != record.family_id }
  end
end
