class Pursuit < ApplicationRecord
  RECENT_ENTRIES = 20

  belongs_to :family
  has_and_belongs_to_many :children
  has_and_belongs_to_many :entries
  has_and_belongs_to_many :activities

  validates :name, :started_on, presence: true
  validates :children, same_family: true
  validates :finished_on, comparison: { greater_than_or_equal_to: :started_on }, allow_nil: true, if: :started_on

  scope :alphabetically, -> { order(:name) }
  scope :current, -> { where(finished_on: nil) }
  scope :finished, -> { where.not(finished_on: nil) }

  def current?
    finished_on.nil?
  end

  def finish
    update!(finished_on: Date.current)
  end

  def pick_up
    update!(finished_on: nil)
  end

  def recent_days
    entries.latest_first.limit(RECENT_ENTRIES).includes(:author, :children, :activity, :pursuits).with_attached_photos.group_by(&:happened_on)
  end
end
