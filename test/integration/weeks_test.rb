require "test_helper"

class WeeksTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Date.new(2026, 11, 18)
    sign_in_as users(:alice)
  end

  test "the week shows the family's pursuits" do
    get week_path

    assert_select "a[href=?]", pursuit_path(pursuits(:reading))
    assert_select "a[href=?]", pursuit_path(pursuits(:knots)), count: 0
  end

  test "the log links to the week" do
    get entries_path

    assert_select "a[href=?]", week_path
  end

  test "writing notes for a week" do
    patch week_reflection_path(week: "2026-11-09"), params: { reflection: { notes: entries(:moon).notes } }

    assert_redirected_to week_path(week: Date.new(2026, 11, 9))
    assert_equal entries(:moon).notes, families(:oaks).reflections.find_by!(week_of: Date.new(2026, 11, 9)).notes
  end

  test "a week's notes are the family's own" do
    families(:elms).reflections.create!(week_of: Date.new(2026, 11, 16), notes: entries(:den).notes)

    get week_path

    assert_select "textarea", text: entries(:den).notes, count: 0
  end

  test "the week shows each grown-up's time and the children's choices" do
    families(:oaks).entries.create!(author: users(:bob), happened_on: Date.new(2026, 11, 17), minutes: 45, notes: "Swimming", children: [ children(:sam) ])
    children(:ivy).choose(activities(:painting))

    get week_path

    assert_select ".row-title", text: users(:bob).name
    assert_select "a[href=?] .row-title", activity_path(activities(:painting))
  end

  test "a strange week parameter shows this week" do
    get week_path, params: { week: [ "2026-11-09" ] }

    assert_response :success
  end
end
