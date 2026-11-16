require "test_helper"

class SuggestionsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:bob)
  end

  test "ideas nobody has picked up are suggested on the child's page, newest first" do
    ideas(:famous_paintings).update!(created_at: 1.hour.from_now)

    get child_path(children(:sam))

    suggested = css_select("[id^=suggestion_idea_]").map { it["id"] }
    assert_equal [ dom_id(ideas(:famous_paintings), :suggestion), dom_id(ideas(:boat_in_the_bath), :suggestion) ], suggested
    assert_select "##{dom_id(ideas(:forest_map), :suggestion)}", count: 0
  end

  test "logging from a suggestion follows on from it, and it stops being suggested" do
    get new_child_idea_entry_path(children(:sam), ideas(:boat_in_the_bath))
    assert_select "input[type=hidden][name=?][value=?]", "entry[suggestion_id]", ideas(:boat_in_the_bath).id.to_s

    post child_entries_path(children(:sam)), params: { entry: { suggestion_id: ideas(:boat_in_the_bath).id, happened_on: Date.current,
      what_we_did: ideas(:boat_in_the_bath).description } }
    follow_redirect!

    follow_up = children(:sam).entries.last
    assert_equal ideas(:boat_in_the_bath), follow_up.suggestion
    assert_select "##{dom_id(ideas(:boat_in_the_bath), :suggestion)}", count: 0
    assert_select "##{dom_id(ideas(:boat_in_the_bath))} a[href$=?]", "##{dom_id(follow_up)}"
    assert_select "##{dom_id(follow_up)} a[href$=?]", "##{dom_id(entries(:painting))}"
  end

  test "setting a suggestion aside" do
    post child_idea_set_aside_path(children(:sam), ideas(:boat_in_the_bath))

    assert_redirected_to child_path(children(:sam))
    follow_redirect!
    assert_select "##{dom_id(ideas(:boat_in_the_bath), :suggestion)}", count: 0
    assert_select "##{dom_id(ideas(:boat_in_the_bath))}"
  end

  test "suggestions are only on the latest page of the log" do
    get child_path(children(:sam), through: Date.current - 30)

    assert_select "[id^=suggestion_idea_]", count: 0
  end

  test "other children's ideas are out of reach" do
    get new_child_idea_entry_path(children(:sam), ideas(:forest_map))
    assert_response :not_found

    post child_idea_set_aside_path(children(:wren), ideas(:forest_map))
    assert_response :not_found
    assert_not ideas(:forest_map).reload.set_aside?
  end

  test "an entry can't follow on from another child's idea" do
    assert_no_difference -> { Entry.count } do
      post child_entries_path(children(:sam)), params: { entry: { suggestion_id: ideas(:forest_map).id, happened_on: Date.current,
        what_we_did: entries(:painting).what_we_did } }
    end

    assert_response :unprocessable_content
  end
end
