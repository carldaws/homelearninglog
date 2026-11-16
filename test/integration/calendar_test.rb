require "test_helper"

class CalendarTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Date.new(2026, 11, 18)
    sign_in_as users(:alice)
  end

  test "the calendar shows the child's week" do
    get child_calendar_path(children(:sam))

    assert_select "h3 a[href^=?]", edit_child_event_path(children(:sam), events(:art_class))
    assert_select "h3 a[href^=?]", edit_child_event_path(children(:sam), events(:visit))
    assert_select "h3 a[href^=?]", edit_child_event_path(children(:wren), events(:swimming)), count: 0
  end

  test "moving between weeks" do
    get child_calendar_path(children(:sam), week: "2026-11-23")

    assert_select "h3 a[href^=?]", edit_child_event_path(children(:sam), events(:art_class))
    assert_select "h3 a[href^=?]", edit_child_event_path(children(:sam), events(:visit)), count: 0
  end

  test "adding a repeating event" do
    assert_difference -> { children(:sam).events.count } do
      post child_events_path(children(:sam)), params: { event: { title: events(:art_class).title, starts_on: "2026-11-19", start_time: "13:00", end_time: "14:00",
        repeats: "fortnightly", repeats_until: "2027-03-31", grown_up_id: users(:alice).id } }
    end

    event = children(:sam).events.order(:created_at).last
    assert_redirected_to child_calendar_path(children(:sam), week: event.starts_on)
    assert event.fortnightly_repeats?
    assert_equal users(:alice), event.grown_up
  end

  test "an event needs a title" do
    post child_events_path(children(:sam)), params: { event: { title: "", starts_on: "2026-11-19" } }

    assert_response :unprocessable_content
  end

  test "editing an event" do
    patch child_event_path(children(:sam), events(:art_class)), params: { event: { repeats_until: "2027-07-19" } }

    assert_redirected_to child_calendar_path(children(:sam), week: events(:art_class).starts_on)
    assert_equal Date.new(2027, 7, 19), events(:art_class).reload.repeats_until
  end

  test "editing an event returns to the week it was opened from" do
    get child_calendar_path(children(:sam), week: "2026-11-30")
    assert_select "a[href=?]", edit_child_event_path(children(:sam), events(:art_class), week: Date.new(2026, 11, 30))

    patch child_event_path(children(:sam), events(:art_class), week: "2026-11-30"), params: { event: { title: events(:visit).title } }

    assert_redirected_to child_calendar_path(children(:sam), week: "2026-11-30")
  end

  test "adding an event from another week starts in that week" do
    get child_calendar_path(children(:sam), week: "2026-12-09")
    assert_select "a[href=?]", new_child_event_path(children(:sam), date: Date.new(2026, 12, 7))

    get new_child_event_path(children(:sam), date: "2026-12-07")
    assert_select "#event_starts_on[value=?]", "2026-12-07"
  end

  test "deleting an event" do
    assert_difference -> { children(:sam).events.count }, -1 do
      delete child_event_path(children(:sam), events(:art_class))
    end
  end

  test "cancelling and restoring one date" do
    post child_event_occurrence_cancellation_path(children(:sam), events(:art_class), "2026-11-23")
    assert_redirected_to child_calendar_path(children(:sam), week: Date.new(2026, 11, 23))
    assert events(:art_class).cancellations.exists?(cancelled_on: Date.new(2026, 11, 23))

    delete child_event_occurrence_cancellation_path(children(:sam), events(:art_class), "2026-11-23")
    assert_not events(:art_class).cancellations.exists?(cancelled_on: Date.new(2026, 11, 23))
  end

  test "dates an event doesn't happen on are not found" do
    post child_event_occurrence_cancellation_path(children(:sam), events(:art_class), "2026-11-24")
    assert_response :not_found

    get new_child_event_occurrence_entry_path(children(:sam), events(:art_class), "2026-02-31")
    assert_response :not_found
  end

  test "logging an event starts from it" do
    get new_child_event_occurrence_entry_path(children(:sam), events(:art_class), "2026-11-16")

    assert_select "input[type=hidden][name=?][value=?]", "entry[event_id]", events(:art_class).id.to_s
    assert_select "#entry_happened_on[value=?]", "2026-11-16"
  end

  test "a logged event stops asking to be logged" do
    get child_path(children(:sam))
    assert_select "a[href=?]", new_child_event_occurrence_entry_path(children(:sam), events(:art_class), "2026-11-16"), count: 0

    travel_to Date.new(2026, 11, 17)
    get child_path(children(:sam))
    assert_select "a[href=?]", new_child_event_occurrence_entry_path(children(:sam), events(:art_class), "2026-11-16")

    post child_entries_path(children(:sam)), params: { entry: { event_id: events(:art_class).id, happened_on: "2026-11-16", notes: entries(:painting).notes } }
    get child_path(children(:sam))
    assert_select "a[href=?]", new_child_event_occurrence_entry_path(children(:sam), events(:art_class), "2026-11-16"), count: 0
  end

  test "a cancelled date can be restored, and one-off events can't be cancelled" do
    events(:art_class).occurrence_on(Date.new(2026, 11, 16)).cancel

    get child_calendar_path(children(:sam))

    assert_select "form[action=?]:has(input[name=_method][value=delete])", child_event_occurrence_cancellation_path(children(:sam), events(:art_class), "2026-11-16")
    assert_select "form[action=?]", child_event_occurrence_cancellation_path(children(:sam), events(:visit), "2026-11-21"), count: 0
  end

  test "only dates that have started can be logged" do
    get child_calendar_path(children(:sam), week: "2026-11-23")

    assert_select "a[href=?]", new_child_event_occurrence_entry_path(children(:sam), events(:art_class), "2026-11-23"), count: 0
  end

  test "other children's events are out of reach" do
    get edit_child_event_path(children(:wren), events(:swimming))
    assert_response :not_found

    get new_child_event_occurrence_entry_path(children(:wren), events(:swimming), "2026-11-18")
    assert_response :not_found

    delete child_event_occurrence_cancellation_path(children(:wren), events(:swimming), "2026-11-18")
    assert_response :not_found

    post child_event_occurrence_cancellation_path(children(:wren), events(:swimming), "2026-11-18")
    assert_response :not_found

    delete child_event_path(children(:wren), events(:swimming))
    assert_response :not_found

    get edit_child_event_path(children(:sam), events(:swimming))
    assert_response :not_found
  end

  test "the grown-up taking a child has to be one of theirs" do
    patch child_event_path(children(:sam), events(:art_class)), params: { event: { grown_up_id: users(:carol).id } }

    assert_response :unprocessable_content
    assert_equal users(:bob), events(:art_class).reload.grown_up
  end
end
