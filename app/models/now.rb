class Now
  attr_reader :child

  def initialize(child)
    @child = child
  end

  def occurrences
    @occurrences ||= [ *unlogged_from_yesterday, *today ]
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
