class Reflection < ApplicationRecord
  belongs_to :family

  validates :week_of, presence: true, uniqueness: { scope: :family_id }
end
