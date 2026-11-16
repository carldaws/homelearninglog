class Log
  WEEKS_PER_PAGE = 4

  attr_reader :child, :through

  def initialize(child, through: nil)
    @child = child
    @through = (DateParam.cast(through) || Date.current).end_of_week
  end

  def occurrences
    @occurrences ||= latest? ? [ *unlogged_from_yesterday, *today ] : []
  end

  def suggestions
    @suggestions ||= latest? ? child.suggestions.to_a : []
  end

  def weeks
    @weeks ||= shown_week_starts.map { Week.new(starts_on: it, entries: entries_by_week.fetch(it, [])) }
  end

  def earlier
    shown_week_starts.last.yesterday if week_starts.size > WEEKS_PER_PAGE
  end

  private
    def latest?
      through >= Date.current
    end

    def unlogged_from_yesterday
      child.occurrences_on(Date.yesterday).select(&:due?)
    end

    def today
      child.occurrences_on(Date.current).reject(&:cancelled?)
    end

    def week_starts
      @week_starts ||= child.entries.where(happened_on: ..through).distinct.order(happened_on: :desc).pluck(:happened_on)
        .map(&:beginning_of_week).uniq.first(WEEKS_PER_PAGE + 1)
    end

    def shown_week_starts
      week_starts.first(WEEKS_PER_PAGE)
    end

    def entries_by_week
      @entries_by_week ||= child.entries.where(happened_on: shown_week_starts.last..through).latest_first.preloaded
        .group_by { it.happened_on.beginning_of_week }
    end
end
