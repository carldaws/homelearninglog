require "test_helper"

class CalendarFeedTest < ActiveSupport::TestCase
  setup do
    travel_to Date.new(2026, 11, 18)
  end

  test "timed events are given in UTC, whatever the clocks are doing" do
    events(:art_class).update!(repeats_until: Date.new(2027, 4, 5))

    starts = vevents.map { it["DTSTART"] }

    assert_includes starts, utc(Time.zone.local(2026, 11, 16, 10))
    assert_includes starts, utc(Time.zone.local(2027, 4, 5, 10))
  end

  test "untimed events last all day" do
    visit = vevents.find { it["SUMMARY"] == events(:visit).title }
    starts_on = visit.fetch("DTSTART;VALUE=DATE")
    ends_on = visit.fetch("DTEND;VALUE=DATE")

    assert_equal events(:visit).starts_on, Date.parse(starts_on)
    assert_equal events(:visit).starts_on.tomorrow, Date.parse(ends_on)
  end

  test "cancelled dates are left out" do
    events(:art_class).occurrence_on(Date.new(2026, 11, 23)).cancel
    cancelled = "#{events(:art_class).id}-#{Date.new(2026, 11, 23).iso8601}@"
    following = "#{events(:art_class).id}-#{Date.new(2026, 11, 30).iso8601}@"

    uids = vevents.map { it["UID"] }

    assert uids.none? { it.start_with?(cancelled) }
    assert uids.any? { it.start_with?(following) }
  end

  test "only the family's own events are in its feed" do
    assert_not_includes vevents.map { it["SUMMARY"] }, events(:swimming).title
  end

  test "the description says who's going" do
    art_class = vevents.find { it["SUMMARY"] == events(:art_class).title }
    description = art_class.fetch("DESCRIPTION")

    assert_includes description, children(:sam).name
    assert_includes description, users(:bob).name
  end

  test "an event with no end time has no end" do
    events(:art_class).update!(end_time: nil)

    art_class = vevents.find { it["SUMMARY"] == events(:art_class).title }

    assert art_class.key?("DTSTART")
    assert_not art_class.key?("DTEND")
  end

  test "text is escaped and long lines are folded" do
    title = "Gran; Grandad, and a very long line of text that goes on and on well past the limit"
    events(:visit).update!(title:)

    lines = CalendarFeed.new(families(:oaks)).to_ics.split("\r\n")
    summary = vevents.map { it["SUMMARY"] }.find { it.start_with?(title.first(4)) }
    unescaped = summary.gsub(/\\([\\;,])/, '\1')

    assert lines.all? { it.bytesize <= CalendarFeed::MAXIMUM_LINE_OCTETS }
    assert_not_equal title, summary
    assert_equal title, unescaped
  end

  private
    def vevents
      ics = CalendarFeed.new(families(:oaks)).to_ics.gsub("\r\n ", "")

      ics.split("\r\n").slice_before("BEGIN:VEVENT").drop(1).map do |lines|
        lines.drop(1).take_while { it != "END:VEVENT" }.to_h { it.split(":", 2) }
      end
    end

    def utc(time)
      time.utc.strftime("%Y%m%dT%H%M%SZ")
    end
end
