class Idea < ApplicationRecord
  belongs_to :entry
  has_many :follow_ups, -> { order(:happened_on, :created_at) }, class_name: "Entry", foreign_key: :followed_idea_id, inverse_of: :followed_idea, dependent: :nullify

  validates :description, presence: true

  scope :not_followed_up, -> { where.missing(:follow_ups) }
  scope :suggested, -> { not_followed_up.where(set_aside_at: nil) }
  scope :set_aside, -> { not_followed_up.where.not(set_aside_at: nil) }

  def set_aside
    update!(set_aside_at: Time.current)
  end

  def bring_back
    update!(set_aside_at: nil)
  end

  def set_aside?
    set_aside_at.present?
  end
end
