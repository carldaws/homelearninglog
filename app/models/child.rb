class Child < ApplicationRecord
  has_many :entries, dependent: :restrict_with_error
  has_many :ideas, through: :entries
  has_many :events, dependent: :restrict_with_error
  # Removing a child takes everyone's access with it, so Access's last-grown-up check mustn't run
  has_many :accesses, dependent: :delete_all
  has_many :grown_ups, through: :accesses, source: :user
  has_and_belongs_to_many :invitations

  validates :name, presence: true

  scope :alphabetically, -> { order(:name) }

  def draft_entry(**attributes)
    entries.build(happened_on: Date.current, **attributes)
  end

  def draft_event(on: nil, **attributes)
    events.build(starts_on: DateParam.cast(on) || Date.current, **attributes)
  end

  def suggestions
    Idea.suggested.where(entry: entries).order(created_at: :desc, id: :desc).includes(entry: :author)
  end

  def log(through: nil)
    Log.new(self, through:)
  end

  def week(containing: nil)
    Week.new(self, containing:)
  end

  def occurrences_on(date)
    occurrences_between(date..date)
  end

  def occurrences_between(dates)
    events.between(dates).includes(:cancellations, :grown_up, :entries)
      .flat_map { it.occurrences_between(dates) }
      .sort_by { [ it.date, it.all_day? ? 0 : 1, it.start_time.to_i ] }
  end

  def removable?
    entries.none? && events.none?
  end
end
