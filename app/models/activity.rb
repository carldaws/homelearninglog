class Activity < ApplicationRecord
  include Pursuable

  belongs_to :family
  has_many :entries, dependent: :nullify
  has_many :events, dependent: :nullify

  validates :name, presence: true
  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24.hours.in_minutes }, allow_nil: true

  scope :alphabetically, -> { order(:name) }

  def draft_event
    family.draft_event(activity: self, title: name)
  end

  def draft_entry
    family.draft_entry(activity: self, minutes:, pursuits: pursuits.current)
  end
end
