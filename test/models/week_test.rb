require "test_helper"

class WeekTest < ActiveSupport::TestCase
  test "a week runs Monday to Sunday" do
    week = children(:sam).week(containing: "2026-11-18")

    assert_equal Date.new(2026, 11, 16)..Date.new(2026, 11, 22), week.dates
    assert_equal Date.new(2026, 11, 9), week.previous
    assert_equal Date.new(2026, 11, 23), week.following
  end

  test "each day has its events" do
    days = children(:sam).week(containing: "2026-11-18").days

    assert_equal 7, days.size
    assert_equal [ events(:art_class) ], days[Date.new(2026, 11, 16)].map(&:event)
    assert_equal [ events(:visit) ], days[Date.new(2026, 11, 21)].map(&:event)
    assert_empty days[Date.new(2026, 11, 17)]
  end

  test "nonsense weeks show this week" do
    assert children(:sam).week(containing: "not a date").current?
    assert children(:sam).week(containing: [ "2026-11-18" ]).current?
  end
end
