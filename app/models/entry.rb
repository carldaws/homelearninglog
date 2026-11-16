class Entry < ApplicationRecord
  MAXIMUM_PHOTOS = 12
  SUGGESTED_MINUTES = [ 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360 ].freeze

  belongs_to :child
  belongs_to :author, class_name: "User"
  belongs_to :event, optional: true
  belongs_to :suggestion, class_name: "Idea", optional: true, inverse_of: :follow_ups
  has_many :ideas, -> { order(:id) }, dependent: :destroy, inverse_of: :entry

  accepts_nested_attributes_for :ideas, reject_if: :new_and_blank_idea?

  has_many_attached :photos do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 600, 600 ], format: :webp, saver: { strip: true }
    attachable.variant :large, resize_to_limit: [ 2000, 2000 ], format: :webp, saver: { strip: true }
  end

  validates :happened_on, presence: true, comparison: { less_than_or_equal_to: -> { Date.current } }
  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24.hours.in_minutes }, allow_nil: true
  validates :photos, photo: true
  validate :says_what_we_did
  validate :event_belongs_to_the_child
  validate :suggestion_belongs_to_the_child
  validate :not_too_many_photos

  scope :latest_first, -> { order(happened_on: :desc, created_at: :desc) }
  scope :preloaded, -> { includes(:author, :event, suggestion: :entry, ideas: :follow_ups).with_attached_photos }

  before_validation :forget_blanked_ideas

  def heading
    event.title if event.present?
  end

  def saved_photos
    photos.select(&:persisted?)
  end

  private
    def new_and_blank_idea?(attributes)
      attributes["id"].blank? && attributes["description"].blank?
    end

    def forget_blanked_ideas
      ideas.each { it.mark_for_destruction if it.description.blank? }
    end

    def says_what_we_did
      errors.add(:base, :empty) if what_we_did.blank? && !photos.attached?
    end

    def event_belongs_to_the_child
      errors.add(:event, :invalid) if event.present? && event.child_id != child_id
    end

    def suggestion_belongs_to_the_child
      errors.add(:suggestion, :invalid) if suggestion.present? && suggestion.entry.child_id != child_id
    end

    def not_too_many_photos
      errors.add(:base, :too_many_photos, count: MAXIMUM_PHOTOS) if photos.size > MAXIMUM_PHOTOS
    end
end
