class Log
  DAYS_PER_PAGE = 10

  attr_reader :family, :through

  def initialize(family, through: nil)
    @family = family
    @through = ActiveModel::Type::Date.new.cast(through) || Date.current
  end

  def days
    entries.group_by(&:happened_on)
  end

  def empty?
    dates.none?
  end

  def earlier
    dates.last.yesterday if dates.any? && family.entries.where(happened_on: ...dates.last).exists?
  end

  def minutes_this_week
    family.entries.where(happened_on: Date.current.all_week).sum(:minutes)
  end

  private
    def dates
      @dates ||= family.entries.where(happened_on: ..through).distinct.order(happened_on: :desc).limit(DAYS_PER_PAGE).pluck(:happened_on)
    end

    def entries
      family.entries.where(happened_on: dates).latest_first.includes(:author, :children).with_attached_photos
    end
end
