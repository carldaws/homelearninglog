class Occurrence
  attr_reader :event, :date

  delegate :family, :title, :start_time, :end_time, :minutes, :children, :grown_up, :activity, :pursuits, to: :event

  def initialize(event, date)
    @event = event
    @date = date
  end

  def cancelled?
    event.cancelled_on?(date)
  end

  def cancel
    event.cancellations.create_or_find_by!(cancelled_on: date)
  end

  def restore
    event.cancellations.where(cancelled_on: date).destroy_all
  end

  def started?
    starts_at.present? ? !starts_at.future? : date <= Date.current
  end

  def due?
    started? && !cancelled? && !logged?
  end

  def logged?
    event.entries.exists?(happened_on: date)
  end

  def repeats?
    !event.never_repeats?
  end

  def all_day?
    start_time.nil?
  end

  def draft_entry
    family.draft_entry(event:, activity:, happened_on: date, minutes:, children:, pursuits: pursuits.current)
  end

  def starts_at
    on_the_day(start_time) if start_time.present?
  end

  def ends_at
    on_the_day(end_time) if end_time.present?
  end

  private
    def on_the_day(time)
      date.in_time_zone.change(hour: time.hour, min: time.min)
    end
end
