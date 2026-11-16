require "test_helper"

class PursuitsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  test "the family's pursuits, current and finished" do
    get pursuits_path

    assert_select "a[href=?]", pursuit_path(pursuits(:reading))
    assert_select "a[href=?]", pursuit_path(pursuits(:dinosaurs))
    assert_select "a[href=?]", pursuit_path(pursuits(:knots)), count: 0
  end

  test "adding a pursuit" do
    assert_difference -> { families(:oaks).pursuits.count } do
      post pursuits_path, params: { pursuit: { name: pursuits(:knots).name, started_on: "2026-11-01", child_ids: [ children(:ivy).id ] } }
    end

    pursuit = families(:oaks).pursuits.order(:created_at).last
    assert_redirected_to pursuit_path(pursuit)
    assert_equal [ children(:ivy) ], pursuit.children
  end

  test "a pursuit shows its activities and entries" do
    get pursuit_path(pursuits(:reading))

    assert_select "a[href=?]", activity_path(activities(:painting))
    assert_select "##{dom_id(entries(:moon))}"
  end

  test "finishing and picking up a pursuit" do
    post pursuit_finish_path(pursuits(:reading))
    assert_not pursuits(:reading).reload.current?

    delete pursuit_finish_path(pursuits(:reading))
    assert pursuits(:reading).reload.current?
  end

  test "entries and activities can be part of pursuits" do
    post entries_path, params: { entry: { notes: entries(:moon).notes, happened_on: Date.current,
      child_ids: [ children(:sam).id ], pursuit_ids: [ pursuits(:reading).id ] } }
    assert_equal [ pursuits(:reading) ], families(:oaks).entries.order(:created_at).last.pursuits

    patch activity_path(activities(:forest_school)), params: { activity: { pursuit_ids: [ pursuits(:reading).id ] } }
    assert_equal [ pursuits(:reading) ], activities(:forest_school).reload.pursuits
  end

  test "deleting a pursuit keeps its entries" do
    delete pursuit_path(pursuits(:reading))

    assert_redirected_to pursuits_path
    assert Entry.exists?(entries(:moon).id)
  end

  test "other families' pursuits are out of reach" do
    get pursuit_path(pursuits(:knots))
    assert_response :not_found

    post pursuit_finish_path(pursuits(:knots))
    assert_response :not_found

    delete pursuit_path(pursuits(:knots))
    assert_response :not_found
  end
end
