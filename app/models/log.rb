class Log
  DAYS_PER_PAGE = 10

  attr_reader :family, :through

  def initialize(family, through: nil)
    @family = family
    @through = ActiveModel::Type::Date.new.cast(through) || Date.current
  end

  def days
    dates.index_with { |date| entries.fetch(date, []) }
  end

  def unlogged
    @unlogged ||= latest? ? recently_due.group_by(&:date) : {}
  end

  def earlier
    entry_dates.last.yesterday if entry_dates.any? && family.entries.where(happened_on: ...entry_dates.last).exists?
  end

  def minutes_this_week
    family.entries.where(happened_on: Date.current.all_week).sum(:minutes)
  end

  private
    def latest?
      through >= Date.current
    end

    def recently_due
      family.occurrences_between(Date.yesterday..Date.current).select(&:due?)
    end

    def dates
      (entry_dates + unlogged.keys).uniq.sort.reverse
    end

    def entry_dates
      @entry_dates ||= family.entries.where(happened_on: ..through).distinct.order(happened_on: :desc).limit(DAYS_PER_PAGE).pluck(:happened_on)
    end

    def entries
      @entries ||= family.entries.where(happened_on: entry_dates).latest_first
        .includes(:author, :children, :activity, :event, :pursuits).with_attached_photos.group_by(&:happened_on)
    end
end
