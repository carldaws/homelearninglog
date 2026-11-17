class Now
  attr_reader :child

  def initialize(child)
    @child = child
  end

  def days
    @days ||= { Date.current => today, Date.yesterday => unlogged_from_yesterday }.compact_blank
  end

  def suggestions
    @suggestions ||= child.suggestions.to_a
  end

  def set_aside_ideas
    @set_aside_ideas ||= child.set_aside_ideas.to_a
  end

  private
    def unlogged_from_yesterday
      child.occurrences_on(Date.yesterday).select(&:due?)
    end

    def today
      child.occurrences_on(Date.current).reject(&:cancelled?)
    end
end
