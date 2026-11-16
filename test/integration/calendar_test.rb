require "test_helper"

class CalendarTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Date.new(2026, 11, 18)
    sign_in_as users(:alice)
  end

  test "the calendar shows the family's week" do
    get calendar_path

    assert_select "h3 a[href=?]", edit_event_path(events(:art_class))
    assert_select "h3 a[href=?]", edit_event_path(events(:visit))
    assert_select "h3 a[href=?]", edit_event_path(events(:swimming)), count: 0
  end

  test "moving between weeks" do
    get calendar_path(week: "2026-11-23")

    assert_select "h3 a[href=?]", edit_event_path(events(:art_class))
    assert_select "h3 a[href=?]", edit_event_path(events(:visit)), count: 0
  end

  test "adding a repeating event" do
    assert_difference -> { families(:oaks).events.count } do
      post events_path, params: { event: { title: events(:art_class).title, starts_on: "2026-11-19", start_time: "13:00", end_time: "14:00",
        repeats: "fortnightly", repeats_until: "2027-03-31", child_ids: [ children(:ivy).id ], grown_up_id: users(:alice).id } }
    end

    event = families(:oaks).events.order(:created_at).last
    assert_redirected_to calendar_path(week: event.starts_on)
    assert event.fortnightly_repeats?
    assert_equal users(:alice), event.grown_up
  end

  test "an event needs a title" do
    post events_path, params: { event: { title: "", starts_on: "2026-11-19", child_ids: [ children(:ivy).id ] } }

    assert_response :unprocessable_content
  end

  test "editing an event" do
    patch event_path(events(:art_class)), params: { event: { repeats_until: "2027-07-19" } }

    assert_equal Date.new(2027, 7, 19), events(:art_class).reload.repeats_until
  end

  test "deleting an event" do
    assert_difference -> { families(:oaks).events.count }, -1 do
      delete event_path(events(:art_class))
    end
  end

  test "cancelling and restoring one date" do
    post event_occurrence_cancellation_path(events(:art_class), "2026-11-23")
    assert_redirected_to calendar_path(week: Date.new(2026, 11, 23))
    assert events(:art_class).cancellations.exists?(cancelled_on: Date.new(2026, 11, 23))

    delete event_occurrence_cancellation_path(events(:art_class), "2026-11-23")
    assert_not events(:art_class).cancellations.exists?(cancelled_on: Date.new(2026, 11, 23))
  end

  test "dates an event doesn't happen on are not found" do
    post event_occurrence_cancellation_path(events(:art_class), "2026-11-24")
    assert_response :not_found

    get new_event_occurrence_entry_path(events(:art_class), "2026-02-31")
    assert_response :not_found
  end

  test "logging an event starts from it" do
    get new_event_occurrence_entry_path(events(:art_class), "2026-11-16")

    assert_select "input[type=hidden][name=?][value=?]", "entry[event_id]", events(:art_class).id.to_s
    assert_select "#entry_happened_on[value=?]", "2026-11-16"
  end

  test "a logged event stops asking to be logged" do
    get entries_path
    assert_select "a[href=?]", new_event_occurrence_entry_path(events(:art_class), "2026-11-16"), count: 0

    travel_to Date.new(2026, 11, 17)
    get entries_path
    assert_select "a[href=?]", new_event_occurrence_entry_path(events(:art_class), "2026-11-16")

    post entries_path, params: { entry: { event_id: events(:art_class).id, happened_on: "2026-11-16", notes: entries(:painting).notes,
      child_ids: [ children(:sam).id ] } }
    get entries_path
    assert_select "a[href=?]", new_event_occurrence_entry_path(events(:art_class), "2026-11-16"), count: 0
  end

  test "an activity can be put on the calendar" do
    get new_activity_event_path(activities(:painting))

    assert_select "#event_title[value=?]", activities(:painting).name
    assert_select "#event_activity_id option[selected][value=?]", activities(:painting).id.to_s
  end

  test "people without a family are sent to start one, even from an old link" do
    delete session_path
    sign_in_as users(:dan)

    get new_event_occurrence_entry_path(events(:art_class), "2026-11-16")
    assert_redirected_to new_family_path

    post event_occurrence_cancellation_path(events(:art_class), "2026-11-23")
    assert_redirected_to new_family_path
  end

  test "other families' events are out of reach" do
    get edit_event_path(events(:swimming))
    assert_response :not_found

    post event_occurrence_cancellation_path(events(:swimming), "2026-11-18")
    assert_response :not_found

    delete event_path(events(:swimming))
    assert_response :not_found
  end
end
