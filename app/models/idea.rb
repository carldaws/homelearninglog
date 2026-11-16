class Idea < ApplicationRecord
  belongs_to :entry

  validates :description, presence: true
end
