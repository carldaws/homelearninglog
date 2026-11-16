class Week
  attr_reader :child, :starts_on

  def initialize(child, containing: nil)
    @child = child
    @starts_on = (DateParam.cast(containing) || Date.current).beginning_of_week
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

  private
    def occurrences
      @occurrences ||= child.occurrences_between(dates)
    end
end
