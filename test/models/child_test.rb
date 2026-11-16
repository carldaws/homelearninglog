require "test_helper"

class ChildTest < ActiveSupport::TestCase
  test "a child needs a name" do
    child = users(:dan).children.create(name: "")

    assert_not child.persisted?
    assert child.errors.of_kind?(:name, :blank)
  end

  test "creating a child links them to the grown-up" do
    child = users(:dan).children.create!(name: children(:wren).name)

    assert_equal [ users(:dan) ], child.grown_ups
  end

  test "children with nothing recorded can be removed" do
    assert children(:ivy).destroy
  end

  test "children with entries or events can't be removed" do
    assert_not children(:sam).destroy
    assert children(:sam).errors.of_kind?(:base, :"restrict_dependent_destroy.has_many")

    entries(:den).destroy!
    assert_not children(:wren).destroy
  end

  test "a day's events start with the all-day ones, then go by time" do
    child = children(:sam)
    later = child.events.create!(title: events(:visit).title, starts_on: Date.new(2026, 11, 16), start_time: "15:00")
    all_day = child.events.create!(title: events(:visit).title, starts_on: Date.new(2026, 11, 16))

    occurrences = child.occurrences_between(Date.new(2026, 11, 16)..Date.new(2026, 11, 16)).map(&:event)

    assert_equal [ all_day, events(:art_class), later ], occurrences
  end
end
