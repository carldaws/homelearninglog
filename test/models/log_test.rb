require "test_helper"

class LogTest < ActiveSupport::TestCase
  setup do
    travel_to Date.new(2026, 11, 18)
    @child = children(:sam)
    @child.entries.destroy_all
  end

  test "weeks run from the latest, with their days" do
    tuesday = log Date.new(2026, 11, 17)
    monday = log Date.new(2026, 11, 16)
    sunday = log Date.new(2026, 11, 15)

    weeks = @child.log.weeks

    assert_equal [ Date.new(2026, 11, 16), Date.new(2026, 11, 9) ], weeks.map(&:starts_on)
    assert_equal({ Date.new(2026, 11, 17) => [ tuesday ], Date.new(2026, 11, 16) => [ monday ] }, weeks.first.days)
    assert_equal [ sunday ], weeks.second.entries
  end

  test "each week adds up its time" do
    log Date.new(2026, 11, 16), minutes: 90
    log Date.new(2026, 11, 17), minutes: 45
    log Date.new(2026, 11, 17)
    log Date.new(2026, 11, 9), minutes: 30

    assert_equal [ 135, 30 ], @child.log.weeks.map(&:minutes)
  end

  test "weeks with nothing logged are skipped" do
    log Date.new(2026, 11, 16)
    log Date.new(2026, 10, 1)

    assert_equal [ Date.new(2026, 11, 16), Date.new(2026, 9, 28) ], @child.log.weeks.map(&:starts_on)
  end

  test "older weeks are on earlier pages" do
    (0..Log::WEEKS_PER_PAGE).each { log Date.new(2026, 11, 16) - it.weeks }

    first_page = @child.log
    assert_equal Log::WEEKS_PER_PAGE, first_page.weeks.size

    second_page = @child.log(through: first_page.earlier)
    assert_equal [ Date.new(2026, 11, 16) - Log::WEEKS_PER_PAGE.weeks ], second_page.weeks.map(&:starts_on)
    assert_nil second_page.earlier
  end

  test "a child's log only has their own entries" do
    log Date.new(2026, 11, 16)

    assert_not_includes @child.log.weeks.flat_map(&:entries), entries(:den)
  end

  test "nonsense dates show the latest page" do
    assert_equal Date.current, @child.log(through: "not a date").through
  end

  test "today's events are shown, and yesterday's until they're logged" do
    today = @child.events.create!(title: events(:visit).title, starts_on: Date.current)
    yesterday = @child.events.create!(title: events(:visit).title, starts_on: Date.yesterday)
    logged = @child.events.create!(title: events(:visit).title, starts_on: Date.yesterday)
    @child.entries.create!(author: users(:alice), event: logged, happened_on: Date.yesterday, what_we_did: entries(:den).what_we_did)

    assert_equal [ yesterday, today ], @child.log.occurrences.map(&:event)
  end

  test "cancelled events and older ones aren't shown" do
    cancelled = @child.events.create!(title: events(:visit).title, starts_on: Date.current, repeats: :weekly)
    cancelled.occurrence_on(Date.current).cancel
    @child.events.create!(title: events(:visit).title, starts_on: Date.current - 2)

    assert_empty @child.log.occurrences
  end

  test "earlier pages don't show events or suggestions" do
    @child.events.create!(title: events(:visit).title, starts_on: Date.current)
    entry = log Date.current - 60
    entry.ideas.create!(description: ideas(:forest_map).description)

    page = @child.log(through: Date.current - 30)

    assert_empty page.occurrences
    assert_empty page.suggestions
  end

  private
    def log(date, minutes: nil)
      @child.entries.create!(author: users(:alice), happened_on: date, minutes:, what_we_did: entries(:den).what_we_did)
    end
end
