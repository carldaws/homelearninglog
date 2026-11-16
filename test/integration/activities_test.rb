require "test_helper"

class ActivitiesTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  test "the activity menu lists the family's activities" do
    get activities_path

    assert_select "a[href=?]", activity_path(activities(:painting))
    assert_select "a[href=?]", activity_path(activities(:forest_school))
    assert_select "a[href=?]", activity_path(activities(:dens)), count: 0
  end

  test "adding an activity" do
    assert_difference -> { families(:oaks).activities.count } do
      post activities_path, params: { activity: { name: activities(:dens).name, minutes: 45, notes: activities(:painting).notes } }
    end

    activity = families(:oaks).activities.order(:created_at).last
    assert_redirected_to activity_path(activity)
    assert_equal 45, activity.minutes
  end

  test "an activity needs a name" do
    post activities_path, params: { activity: { name: "" } }

    assert_response :unprocessable_content
  end

  test "an activity shows what's been logged from it" do
    get activity_path(activities(:painting))

    assert_select "##{dom_id(entries(:painting))}"
    assert_select "a[href=?]", new_activity_entry_path(activities(:painting))
  end

  test "editing an activity" do
    patch activity_path(activities(:painting)), params: { activity: { minutes: "" } }

    assert_redirected_to activity_path(activities(:painting))
    assert_nil activities(:painting).reload.minutes
  end

  test "deleting an activity" do
    assert_difference -> { families(:oaks).activities.count }, -1 do
      delete activity_path(activities(:painting))
    end

    assert_redirected_to activities_path
    assert Entry.exists?(entries(:painting).id)
  end

  test "logging an activity starts from what it says" do
    get new_activity_entry_path(activities(:painting))

    assert_select "#entry_activity_id option[selected][value=?]", activities(:painting).id.to_s
    assert_select "#entry_minutes option[selected][value=?]", activities(:painting).minutes.to_s
  end

  test "an entry can say which activity it was" do
    post entries_path, params: { entry: { notes: entries(:painting).notes, happened_on: Date.current,
      activity_id: activities(:forest_school).id, child_ids: [ children(:sam).id ] } }

    assert_equal activities(:forest_school), families(:oaks).entries.order(:created_at).last.activity
  end

  test "other families' activities are out of reach" do
    get activity_path(activities(:dens))
    assert_response :not_found

    get new_activity_entry_path(activities(:dens))
    assert_response :not_found

    delete activity_path(activities(:dens))
    assert_response :not_found
  end
end
