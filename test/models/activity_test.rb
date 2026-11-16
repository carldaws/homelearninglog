require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  test "an activity needs a name" do
    activity = families(:oaks).activities.build(name: "")

    assert_not activity.valid?
    assert activity.errors.of_kind?(:name, :blank)
  end

  test "a drafted entry starts from the activity" do
    entry = activities(:painting).draft_entry

    assert_equal activities(:painting), entry.activity
    assert_equal activities(:painting).minutes, entry.minutes
    assert_equal Date.current, entry.happened_on
    assert_equal families(:oaks).children.to_a.sort, entry.children.to_a.sort
  end

  test "deleting an activity keeps its entries" do
    activities(:painting).destroy!

    assert_nil entries(:painting).reload.activity
  end
end
