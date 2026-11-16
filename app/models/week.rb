class Week
  attr_reader :family, :starts_on

  def initialize(family, containing: nil)
    @family = family
    @starts_on = (ActiveModel::Type::Date.new.cast(containing) || Date.current).beginning_of_week
  end

  def dates
    starts_on..starts_on.end_of_week
  end

  def days
    by_date = occurrences.group_by(&:date)
    dates.index_with { by_date.fetch(it, []) }
  end

  def previous
    starts_on.prev_week
  end

  def following
    starts_on.next_week
  end

  def current?
    dates.cover?(Date.current)
  end

  def days_logged
    entries.distinct.count(:happened_on)
  end

  def minutes
    entries.sum(:minutes)
  end

  def minutes_by_grown_up
    @minutes_by_grown_up ||= begin
      by_id = entries.where.not(minutes: nil).group(:author_id).sum(:minutes)
      User.where(id: by_id.keys).alphabetically.index_with { by_id.fetch(it.id) }
    end
  end

  def pursuit_tallies
    @pursuit_tallies ||= begin
      entry_counts = entries.joins(:pursuits).group("pursuits.id").count
      minutes = entries.joins(:pursuits).group("pursuits.id").sum(:minutes)

      family.pursuits.current.alphabetically.map do |pursuit|
        PursuitTally.new(pursuit:, entries: entry_counts.fetch(pursuit.id, 0), minutes: minutes.fetch(pursuit.id, 0))
      end
    end
  end

  def choices
    @choices ||= Choice.where(child: family.children, created_at: dates.first.beginning_of_day..dates.last.end_of_day)
      .includes(:child, :activity).latest_first.to_a
  end

  def reflection
    @reflection ||= family.reflections.find_or_initialize_by(week_of: starts_on)
  end

  private
    def entries
      family.entries.where(happened_on: dates)
    end

    def occurrences
      @occurrences ||= family.occurrences_between(dates)
    end
end
