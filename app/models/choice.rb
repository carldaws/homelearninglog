class Choice < ApplicationRecord
  belongs_to :child
  belongs_to :activity

  delegate :family, :family_id, to: :child

  validates :activity, same_family: true

  scope :latest_first, -> { order(created_at: :desc) }
end
