class Activity < ApplicationRecord
  belongs_to :family
  has_many :entries, dependent: :nullify
  has_many :events, dependent: :nullify

  validates :name, presence: true
  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24.hours.in_minutes }, allow_nil: true

  scope :alphabetically, -> { order(:name) }

  def days
    entries.latest_first.includes(:author, :children).with_attached_photos.group_by(&:happened_on)
  end

  def draft_event
    family.draft_event.tap do |event|
      event.assign_attributes(activity: self, title: name)
    end
  end

  def draft_entry
    family.draft_entry.tap do |entry|
      entry.activity = self
      entry.minutes = minutes
    end
  end
end
