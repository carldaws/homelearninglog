class Pursuit < ApplicationRecord
  belongs_to :family
  has_and_belongs_to_many :children
  has_and_belongs_to_many :entries
  has_and_belongs_to_many :activities

  validates :name, :started_on, presence: true
  validates :started_on, comparison: { less_than_or_equal_to: -> { Date.current } }, allow_nil: true
  validates :children, same_family: true
  validates :finished_on, comparison: { greater_than_or_equal_to: :started_on }, allow_nil: true, if: :started_on?

  scope :alphabetically, -> { order(:name) }
  scope :current, -> { where(finished_on: nil) }
  scope :finished, -> { where.not(finished_on: nil) }
  scope :active_during, ->(dates) { where(started_on: ..dates.end, finished_on: [ nil, dates.begin.. ]) }

  def current?
    finished_on.nil?
  end

  def finished?
    !current?
  end

  def finish
    update!(finished_on: Date.current) if current?
  end

  def pick_up
    update!(finished_on: nil)
  end
end
