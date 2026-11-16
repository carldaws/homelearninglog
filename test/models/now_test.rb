require "test_helper"

class NowTest < ActiveSupport::TestCase
  setup do
    travel_to Date.new(2026, 11, 18)
    @child = children(:sam)
  end

  test "today's events are shown, and yesterday's until they're logged" do
    today = @child.events.create!(title: events(:visit).title, starts_on: Date.current)
    yesterday = @child.events.create!(title: events(:visit).title, starts_on: Date.yesterday)
    logged = @child.events.create!(title: events(:visit).title, starts_on: Date.yesterday)
    @child.entries.create!(author: users(:alice), event: logged, happened_on: Date.yesterday, what_we_did: entries(:den).what_we_did)

    assert_equal [ yesterday, today ], @child.now.occurrences.map(&:event)
  end

  test "cancelled events and older ones aren't shown" do
    @child.events.destroy_all
    cancelled = @child.events.create!(title: events(:swimming).title, starts_on: Date.current, repeats: :weekly)
    cancelled.occurrence_on(Date.current).cancel
    @child.events.create!(title: events(:swimming).title, starts_on: Date.current - 2)

    assert_empty @child.now.occurrences
  end

  test "suggestions and set-aside ideas are kept apart" do
    ideas(:famous_paintings).set_aside

    assert_equal [ ideas(:boat_in_the_bath) ], @child.now.suggestions
    assert_equal [ ideas(:famous_paintings) ], @child.now.set_aside_ideas
  end
end
