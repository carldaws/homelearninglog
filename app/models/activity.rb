class Activity < ApplicationRecord
  belongs_to :family
  has_many :entries, dependent: :nullify
  has_many :events, dependent: :nullify
  has_and_belongs_to_many :pursuits

  validates :name, presence: true
  validates :pursuits, same_family: true
  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24.hours.in_minutes }, allow_nil: true

  scope :alphabetically, -> { order(:name) }

  RECENT_ENTRIES = 20

  def recent_days
    entries.latest_first.limit(RECENT_ENTRIES).includes(:author, :children, :pursuits).with_attached_photos.group_by(&:happened_on)
  end

  def draft_event
    family.draft_event(activity: self, title: name)
  end

  def draft_entry
    family.draft_entry(activity: self, minutes:, pursuits:)
  end
end
