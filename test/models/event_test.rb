require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "weekly events happen every week until they stop" do
    dates = events(:art_class).occurrences_between(Date.new(2026, 11, 1)..Date.new(2026, 12, 31)).map(&:date)

    assert_equal [ Date.new(2026, 11, 2), Date.new(2026, 11, 9), Date.new(2026, 11, 16), Date.new(2026, 11, 23),
      Date.new(2026, 11, 30), Date.new(2026, 12, 7), Date.new(2026, 12, 14) ], dates
  end

  test "fortnightly events skip a week, and can go on forever" do
    dates = events(:swimming).occurrences_between(Date.new(2027, 6, 1)..Date.new(2027, 6, 30)).map(&:date)

    assert_equal [ Date.new(2027, 6, 2), Date.new(2027, 6, 16), Date.new(2027, 6, 30) ], dates
  end

  test "repeats far in the future land on the right day" do
    dates = events(:swimming).occurrences_between(Date.new(9999, 1, 1)..Date.new(9999, 1, 31)).map(&:date)

    assert_equal 2, dates.size
    assert dates.all? { (it - events(:swimming).starts_on).to_i.modulo(14).zero? }
  end

  test "one-off events happen once" do
    assert_equal [ Date.new(2026, 11, 21) ], events(:visit).occurrences_between(Date.new(2026, 11, 1)..Date.new(2026, 11, 30)).map(&:date)
    assert_empty events(:visit).occurrences_between(Date.new(2026, 12, 1)..Date.new(2026, 12, 31))
  end

  test "a cancelled date stays on the calendar, marked as cancelled" do
    occurrence = events(:art_class).occurrence_on(Date.new(2026, 11, 23))

    occurrence.cancel
    assert events(:art_class).reload.occurrence_on(Date.new(2026, 11, 23)).cancelled?

    occurrence.restore
    assert_not events(:art_class).reload.occurrence_on(Date.new(2026, 11, 23)).cancelled?
  end

  test "dates the event doesn't happen on can't be found" do
    assert_raises(ActiveRecord::RecordNotFound) { events(:art_class).occurrence_on(Date.new(2026, 11, 3)) }
  end

  test "times have to make sense" do
    event = events(:art_class)

    event.end_time = "09:00"
    assert event.invalid?
    assert event.errors.of_kind?(:end_time, :greater_than)

    event.start_time = nil
    assert event.invalid?
    assert event.errors.of_kind?(:start_time, :blank)
  end

  test "repeats can't stop before they start" do
    event = events(:art_class)
    event.repeats_until = event.starts_on - 1

    assert event.invalid?
    assert event.errors.of_kind?(:repeats_until, :greater_than_or_equal_to)
  end

  test "the grown-up taking the child has to be one of the child's" do
    event = events(:art_class)
    event.grown_up = users(:carol)

    assert event.invalid?
    assert event.errors.of_kind?(:grown_up, :invalid)
  end

  test "an event that stops repeating forgets when it would have stopped" do
    event = events(:art_class)

    event.update!(repeats: :never, starts_on: event.repeats_until + 1)

    assert_nil event.repeats_until
  end

  test "an unknown repeat is invalid" do
    event = events(:visit)
    event.repeats = "hourly"

    assert event.invalid?
  end

  test "length comes from the times" do
    assert_equal 90, events(:art_class).minutes
    assert_nil events(:visit).minutes
  end

  test "an entry drafted from a date starts from the event" do
    entry = events(:art_class).occurrence_on(Date.new(2026, 11, 16)).draft_entry

    assert_equal events(:art_class), entry.event
    assert_equal Date.new(2026, 11, 16), entry.happened_on
    assert_equal 90, entry.minutes
    assert_equal children(:sam), entry.child
    assert_equal events(:art_class).title, entry.what_we_did
  end

  test "a date is due once it's started and until it's logged" do
    occurrence = events(:art_class).occurrence_on(Date.new(2026, 11, 16))

    travel_to Time.zone.local(2026, 11, 16, 9, 59)
    assert_not occurrence.due?

    travel_to Time.zone.local(2026, 11, 16, 10)
    assert occurrence.due?
    assert_not events(:art_class).occurrence_on(Date.new(2026, 11, 23)).due?

    children(:sam).entries.create!(occurrence.draft_entry.attributes.slice("happened_on", "minutes", "event_id")
      .merge(author: users(:bob), what_we_did: entries(:painting).what_we_did))
    assert_not occurrence.due?
  end
end
