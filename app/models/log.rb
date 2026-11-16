class Log
  WEEKS_PER_PAGE = 4
  WEEK_STARTS_ON = Arel.sql("date_trunc('week', happened_on)::date")

  Week = Data.define(:starts_on, :entries) do
    def days
      entries.group_by(&:happened_on)
    end

    def minutes
      entries.filter_map(&:minutes).sum
    end
  end

  attr_reader :child, :through

  def initialize(child, through: nil)
    @child = child
    @through = DateParam.cast(through) || Date.current
  end

  def occurrences
    @occurrences ||= latest? ? recent_occurrences.select { it.today? ? !it.cancelled? : it.due? } : []
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

    def recent_occurrences
      child.occurrences_between(Date.yesterday..Date.current)
    end

    def week_starts
      @week_starts ||= child.entries.where(happened_on: ..through).group(WEEK_STARTS_ON)
        .order(Arel.sql("#{WEEK_STARTS_ON} DESC")).limit(WEEKS_PER_PAGE + 1).pluck(WEEK_STARTS_ON)
    end

    def shown_week_starts
      week_starts.first(WEEKS_PER_PAGE)
    end

    def entries_by_week
      @entries_by_week ||= child.entries.where(happened_on: shown_week_starts.last..through).latest_first.preloaded
        .group_by { it.happened_on.beginning_of_week }
    end
end
