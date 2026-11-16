class Event < ApplicationRecord
  belongs_to :family
  belongs_to :activity, optional: true
  belongs_to :grown_up, class_name: "User", optional: true
  has_and_belongs_to_many :children
  has_many :cancellations, dependent: :delete_all
  has_many :entries, dependent: :nullify

  enum :repeats, { never: 0, weekly: 1, fortnightly: 2 }, default: :never, suffix: true, validate: true

  validates :title, :starts_on, :children, presence: true
  validates :children, :activity, :grown_up, same_family: true
  validates :start_time, presence: true, if: :end_time
  validates :end_time, comparison: { greater_than: :start_time }, if: -> { start_time.present? && end_time.present? }
  validates :repeats_until, comparison: { greater_than_or_equal_to: :starts_on }, allow_nil: true, if: :starts_on

  scope :between, ->(dates) { where(starts_on: ..dates.end).merge(where(repeats_until: nil).or(where(repeats_until: dates.begin..))) }

  def occurrences_between(dates)
    dates_between(dates).map { Occurrence.new(self, it) }
  end

  def occurrence_on(date)
    occurrences_between(date..date).first || raise(ActiveRecord::RecordNotFound)
  end

  def minutes
    ((end_time - start_time) / 1.minute).to_i if start_time.present? && end_time.present?
  end

  def cancelled_on?(date)
    cancellations.any? { it.cancelled_on == date }
  end

  private
    def dates_between(dates)
      if never_repeats?
        [ starts_on ].select { dates.cover?(it) }
      else
        (starts_on..[ repeats_until, dates.end ].compact.min).step(days_between_repeats).select { dates.cover?(it) }
      end
    end

    def days_between_repeats
      weekly_repeats? ? 7 : 14
    end
end
