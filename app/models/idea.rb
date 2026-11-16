class Idea < ApplicationRecord
  belongs_to :entry
  has_many :follow_ups, -> { order(:happened_on, :created_at) }, class_name: "Entry", foreign_key: :followed_idea_id, inverse_of: :followed_idea, dependent: :nullify

  validates :description, presence: true

  scope :suggested, -> { where(set_aside_at: nil).where.missing(:follow_ups) }

  def set_aside
    update!(set_aside_at: Time.current)
  end

  def set_aside?
    set_aside_at.present?
  end
end
