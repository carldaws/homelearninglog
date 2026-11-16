class Entry < ApplicationRecord
  include Pursuable

  MAXIMUM_PHOTOS = 12
  SUGGESTED_MINUTES = [ 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360 ].freeze

  belongs_to :family
  belongs_to :author, class_name: "User"
  belongs_to :activity, optional: true
  belongs_to :event, optional: true
  has_and_belongs_to_many :children

  has_many_attached :photos do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 600, 600 ], format: :webp, saver: { strip: true }
    attachable.variant :large, resize_to_limit: [ 2000, 2000 ], format: :webp, saver: { strip: true }
  end

  validates :happened_on, presence: true, comparison: { less_than_or_equal_to: -> { Date.current } }
  validates :children, presence: true
  validates :children, :activity, :event, same_family: true
  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24.hours.in_minutes }, allow_nil: true
  validates :photos, photo: true
  validate :has_notes_or_photos
  validate :not_too_many_photos

  scope :latest_first, -> { order(happened_on: :desc, created_at: :desc) }
  scope :preloaded, -> { includes(:author, :children, :activity, :event, :pursuits).with_attached_photos }

  def self.recent_days(limit: 20)
    latest_first.limit(limit).preloaded.group_by(&:happened_on)
  end

  def heading
    if activity.present?
      activity.name
    elsif event.present?
      event.title
    end
  end

  def saved_photos
    photos.select(&:persisted?)
  end

  private
    def has_notes_or_photos
      errors.add(:base, :empty) if notes.blank? && !photos.attached?
    end

    def not_too_many_photos
      errors.add(:base, :too_many_photos, count: MAXIMUM_PHOTOS) if photos.size > MAXIMUM_PHOTOS
    end
end
