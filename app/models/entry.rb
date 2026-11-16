class Entry < ApplicationRecord
  PHOTO_CONTENT_TYPES = %w[ image/jpeg image/png image/webp image/gif image/heic image/heif ].freeze
  MAXIMUM_PHOTO_SIZE = 25.megabytes
  MAXIMUM_PHOTOS = 12
  SUGGESTED_MINUTES = [ 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360 ].freeze

  belongs_to :family
  belongs_to :author, class_name: "User"
  belongs_to :activity, optional: true
  belongs_to :event, optional: true
  has_and_belongs_to_many :children
  has_and_belongs_to_many :pursuits

  has_many_attached :photos do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 600, 600 ], format: :webp, saver: { strip: true }
    attachable.variant :large, resize_to_limit: [ 2000, 2000 ], format: :webp, saver: { strip: true }
  end

  validates :happened_on, presence: true, comparison: { less_than_or_equal_to: -> { Date.current } }
  validates :children, presence: true
  validates :children, :activity, :event, :pursuits, same_family: true
  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24.hours.in_minutes }, allow_nil: true
  validate :has_notes_or_photos
  validate :photos_are_photos

  scope :latest_first, -> { order(happened_on: :desc, created_at: :desc) }

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

    def photos_are_photos
      errors.add(:base, :too_many_photos, count: MAXIMUM_PHOTOS) if photos.size > MAXIMUM_PHOTOS

      photos.each do |photo|
        errors.add(:base, :not_a_photo, filename: photo.filename) unless photo.content_type.in?(PHOTO_CONTENT_TYPES)
        errors.add(:base, :photo_too_big, filename: photo.filename, size: MAXIMUM_PHOTO_SIZE.to_fs(:human_size)) if photo.byte_size > MAXIMUM_PHOTO_SIZE
      end
    end
end
