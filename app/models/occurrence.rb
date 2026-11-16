class Occurrence
  attr_reader :event, :date

  delegate :family, :title, :start_time, :end_time, :minutes, :children, :grown_up, :activity, to: :event

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

  def due?
    date <= Date.current && !cancelled? && !logged?
  end

  def logged?
    event.entries.exists?(happened_on: date)
  end

  def repeats?
    !event.never_repeats?
  end

  def draft_entry
    family.draft_entry.tap do |entry|
      entry.assign_attributes(event:, activity:, happened_on: date, minutes:, children:)
    end
  end

  def starts_at
    date.in_time_zone.change(hour: start_time.hour, min: start_time.min) if start_time.present?
  end

  def ends_at
    date.in_time_zone.change(hour: end_time.hour, min: end_time.min) if end_time.present?
  end
end
