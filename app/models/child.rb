class Child < ApplicationRecord
  has_many :accesses, dependent: :delete_all
  has_many :grown_ups, through: :accesses, source: :user
  has_many :entries, dependent: :destroy
  has_many :ideas, through: :entries
  has_many :events, dependent: :destroy
  has_and_belongs_to_many :invitations

  has_secure_token :calendar_token

  validates :name, presence: true

  scope :alphabetically, -> { order(:name) }

  before_destroy :keep_children_in_use, prepend: true

  def draft_entry(**attributes)
    entries.build(happened_on: Date.current, **attributes)
  end

  def draft_event(on: nil, **attributes)
    events.build(starts_on: DateParam.cast(on) || Date.current, **attributes)
  end

  def suggestions
    ideas.suggested.reorder(created_at: :desc, id: :desc).includes(entry: :author)
  end

  def log(through: nil)
    Log.new(self, through:)
  end

  def week(containing: nil)
    Week.new(self, containing:)
  end

  def occurrences_between(dates)
    events.between(dates).includes(:cancellations, :grown_up)
      .flat_map { it.occurrences_between(dates) }
      .sort_by { [ it.date, it.all_day? ? 0 : 1, it.start_time.to_i ] }
  end

  def removable?
    entries.none? && events.none?
  end

  private
    def keep_children_in_use
      unless removable?
        errors.add(:base, :in_use, name:)
        throw :abort
      end
    end
end
