require "test_helper"

class LogTest < ActiveSupport::TestCase
  test "days run from the latest" do
    log = families(:oaks).log

    assert_equal [ Date.current, Date.yesterday ], log.days.keys
    assert_equal [ entries(:painting) ], log.days[Date.current]
  end

  test "a family's log only has its own entries" do
    assert_not_includes families(:oaks).log.days.values.flatten, entries(:den)
  end

  test "older days are on earlier pages" do
    family = families(:oaks)
    (2..Log::DAYS_PER_PAGE).each do |days_ago|
      family.entries.create!(author: users(:alice), happened_on: Date.current - days_ago, notes: entries(:painting).notes, children: [ children(:sam) ])
    end

    first_page = family.log
    assert_equal Log::DAYS_PER_PAGE, first_page.days.size

    second_page = family.log(through: first_page.earlier)
    assert_equal [ Date.current - Log::DAYS_PER_PAGE ], second_page.days.keys
    assert_nil second_page.earlier
  end

  test "nonsense dates show the latest page" do
    assert_equal Date.current, families(:oaks).log(through: "not a date").through
  end

  test "time is added up for this week" do
    families(:oaks).entries.create!(author: users(:alice), happened_on: Date.current.prev_week, minutes: 90, notes: entries(:moon).notes, children: [ children(:sam) ])

    assert_equal entries(:painting).minutes, families(:oaks).log.minutes_this_week
  end
end
