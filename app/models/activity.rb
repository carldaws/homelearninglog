class Activity < ApplicationRecord
  include Pursuable

  belongs_to :family
  has_many :entries, dependent: :nullify
  has_many :events, dependent: :nullify
  has_many :choices, dependent: :destroy

  has_one_attached :picture do |attachable|
    attachable.variant :tile, resize_to_fill: [ 600, 600 ], format: :webp, saver: { strip: true }
  end

  validates :name, presence: true
  validates :picture, photo: true
  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24.hours.in_minutes }, allow_nil: true

  scope :alphabetically, -> { order(:name) }
  scope :for_children, -> { where(for_children: true) }

  def draft_event
    family.draft_event(activity: self, title: name)
  end

  def draft_entry
    family.draft_entry(activity: self, minutes:, pursuits: pursuits.current)
  end
end
