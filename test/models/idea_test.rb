require "test_helper"

class IdeaTest < ActiveSupport::TestCase
  test "ideas are suggested until they're followed up or set aside" do
    assert_includes Idea.suggested, ideas(:boat_in_the_bath)

    follow_up(ideas(:boat_in_the_bath))
    ideas(:famous_paintings).set_aside

    assert_not_includes Idea.suggested, ideas(:boat_in_the_bath)
    assert_not_includes Idea.suggested, ideas(:famous_paintings)
    assert_includes Idea.suggested, ideas(:forest_map)
  end

  test "ideas set aside are kept apart until they're brought back" do
    ideas(:boat_in_the_bath).set_aside

    assert_equal [ ideas(:boat_in_the_bath) ], children(:sam).set_aside_ideas
    assert_not_includes children(:sam).suggestions, ideas(:boat_in_the_bath)

    ideas(:boat_in_the_bath).bring_back

    assert_empty children(:sam).set_aside_ideas
    assert_includes children(:sam).suggestions, ideas(:boat_in_the_bath)
  end

  test "an idea set aside and then followed up isn't kept apart" do
    ideas(:boat_in_the_bath).set_aside
    follow_up(ideas(:boat_in_the_bath))

    assert_empty children(:sam).set_aside_ideas
  end

  test "a child's suggestions only come from their own log" do
    assert_equal [ ideas(:boat_in_the_bath), ideas(:famous_paintings) ].sort, children(:sam).suggestions.sort
  end

  test "deleting an idea leaves what followed it in the log" do
    entry = follow_up(ideas(:boat_in_the_bath))

    ideas(:boat_in_the_bath).destroy!

    assert_nil entry.reload.followed_idea
  end

  private
    def follow_up(idea)
      children(:sam).entries.create!(author: users(:alice), happened_on: Date.current, what_we_did: entries(:moon).what_we_did, followed_idea: idea)
    end
end
