require "test_helper"

class LogTest < ActiveSupport::TestCase
  test "days run from the latest" do
    log = children(:sam).log

    assert_equal [ Date.current, Date.yesterday ], log.days.keys
    assert_equal [ entries(:painting) ], log.days[Date.current]
    assert_equal [ entries(:moon) ], log.days[Date.yesterday]
  end

  test "a child's log only has their own entries" do
    assert_not_includes children(:sam).log.days.values.flatten, entries(:den)
  end

  test "older days are on earlier pages" do
    child = children(:sam)
    (2..Log::DAYS_PER_PAGE).each do |days_ago|
      child.entries.create!(author: users(:alice), happened_on: Date.current - days_ago, what_we_did: entries(:painting).what_we_did)
    end

    first_page = child.log
    assert_equal Log::DAYS_PER_PAGE, first_page.days.size

    second_page = child.log(through: first_page.earlier)
    assert_equal [ Date.current - Log::DAYS_PER_PAGE ], second_page.days.keys
    assert_nil second_page.earlier
  end

  test "nonsense dates show the latest page" do
    assert_equal Date.current, children(:sam).log(through: "not a date").through
  end

  test "time is added up for this week" do
    children(:sam).entries.create!(author: users(:alice), happened_on: Date.current.prev_week, minutes: 90, what_we_did: entries(:moon).what_we_did)

    assert_equal entries(:painting).minutes, children(:sam).log.minutes_this_week
  end

  test "today's and yesterday's events wait to be logged" do
    travel_to Date.new(2027, 3, 3)
    event = children(:sam).events.create!(title: events(:visit).title, starts_on: Date.yesterday, repeats: :weekly)

    assert_equal [ event ], children(:sam).log.unlogged.fetch(Date.yesterday).map(&:event)
  end

  test "logged and cancelled events stop waiting" do
    travel_to Date.new(2027, 3, 3)
    logged = children(:sam).events.create!(title: events(:visit).title, starts_on: Date.current)
    cancelled = children(:sam).events.create!(title: events(:visit).title, starts_on: Date.current, repeats: :weekly)
    children(:sam).entries.create!(author: users(:alice), event: logged, happened_on: Date.current, what_we_did: entries(:painting).what_we_did)
    cancelled.occurrence_on(Date.current).cancel

    assert_empty children(:sam).log.unlogged
  end

  test "a day can have events waiting alongside its entries" do
    travel_to Date.new(2027, 3, 3)
    child = children(:sam)
    child.events.create!(title: events(:visit).title, starts_on: Date.current)
    entry = child.entries.create!(author: users(:alice), happened_on: Date.current, what_we_did: entries(:painting).what_we_did)
    log = child.log

    assert_equal [ entry ], log.days.fetch(Date.current)
    assert_equal 1, log.unlogged.fetch(Date.current).size
  end

  test "events from before yesterday don't wait to be logged" do
    travel_to Date.new(2027, 3, 3)
    children(:sam).events.create!(title: events(:visit).title, starts_on: Date.current - 2)

    assert_empty children(:sam).log.unlogged
  end

  test "earlier pages don't ask for anything to be logged" do
    travel_to Date.new(2027, 3, 3)
    children(:sam).events.create!(title: events(:visit).title, starts_on: Date.current)

    assert_empty children(:sam).log(through: Date.current - 30).unlogged
  end
end
