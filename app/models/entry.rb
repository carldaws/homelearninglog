class Entry < ApplicationRecord
  MAXIMUM_PHOTOS = 12
  SUGGESTED_MINUTES = [ 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360 ].freeze

  belongs_to :child
  belongs_to :author, class_name: "User"
  belongs_to :event, optional: true

  has_many_attached :photos do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 600, 600 ], format: :webp, saver: { strip: true }
    attachable.variant :large, resize_to_limit: [ 2000, 2000 ], format: :webp, saver: { strip: true }
  end

  validates :happened_on, presence: true, comparison: { less_than_or_equal_to: -> { Date.current } }
  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24.hours.in_minutes }, allow_nil: true
  validates :photos, photo: true
  validate :has_notes_or_photos
  validate :event_belongs_to_the_child
  validate :not_too_many_photos

  scope :latest_first, -> { order(happened_on: :desc, created_at: :desc) }
  scope :preloaded, -> { includes(:author, :event).with_attached_photos }

  def heading
    event.title if event.present?
  end

  def saved_photos
    photos.select(&:persisted?)
  end

  private
    def has_notes_or_photos
      errors.add(:base, :empty) if notes.blank? && !photos.attached?
    end

    def event_belongs_to_the_child
      errors.add(:event, :invalid) if event.present? && event.child_id != child_id
    end

    def not_too_many_photos
      errors.add(:base, :too_many_photos, count: MAXIMUM_PHOTOS) if photos.size > MAXIMUM_PHOTOS
    end
end
