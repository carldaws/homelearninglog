class Child < ApplicationRecord
  belongs_to :family

  validates :name, presence: true
end
