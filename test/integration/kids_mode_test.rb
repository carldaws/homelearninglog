require "test_helper"

class KidsModeTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  test "kids' mode shows a child the activities meant for them" do
    post kids_mode_path, params: { child_id: children(:sam).id }
    follow_redirect!

    assert_select "h1", text: children(:sam).name
    assert_select "form[action=?] input[name=activity_id][value=?]", choices_path, activities(:painting).id.to_s
    assert_select "input[name=activity_id][value=?]", activities(:forest_school).id.to_s, count: 0
  end

  test "kids' mode keeps to the kids' menu" do
    post kids_mode_path, params: { child_id: children(:sam).id }

    get entries_path
    assert_redirected_to kids_menu_path

    get family_path
    assert_redirected_to kids_menu_path

    delete session_path
    assert_redirected_to kids_menu_path
  end

  test "choosing an activity" do
    post kids_mode_path, params: { child_id: children(:ivy).id }

    assert_difference -> { children(:ivy).choices.count } do
      post choices_path, params: { activity_id: activities(:painting).id }
    end

    follow_redirect!
    assert_select "h1, span", text: activities(:painting).name
  end

  test "a surprise is one of the activities meant for children" do
    post kids_mode_path, params: { child_id: children(:ivy).id }

    post surprise_path

    assert_equal activities(:painting), children(:ivy).choices.latest_first.first.activity
  end

  test "only activities meant for children can be chosen" do
    post kids_mode_path, params: { child_id: children(:sam).id }

    post choices_path, params: { activity_id: activities(:forest_school).id }
    assert_response :not_found

    post choices_path, params: { activity_id: activities(:dens).id }
    assert_response :not_found
  end

  test "leaving kids' mode takes a grown-up's password" do
    post kids_mode_path, params: { child_id: children(:sam).id }

    delete kids_mode_path, params: { password: "wrong password" }
    get entries_path
    assert_redirected_to kids_menu_path

    delete kids_mode_path, params: { password: FixturePasswords::PASSWORD }
    assert_redirected_to entries_path
    get entries_path
    assert_response :success
  end

  test "guessing the password is slowed down" do
    post kids_mode_path, params: { child_id: children(:sam).id }
    10.times { delete kids_mode_path, params: { password: "wrong password" } }

    delete kids_mode_path, params: { password: FixturePasswords::PASSWORD }

    get entries_path
    assert_redirected_to kids_menu_path
  end

  test "choosing only happens in kids' mode" do
    post choices_path, params: { activity_id: activities(:painting).id }
    assert_redirected_to new_kids_mode_path

    post surprise_path
    assert_redirected_to new_kids_mode_path
  end

  test "another family's child can't be chosen for kids' mode" do
    post kids_mode_path, params: { child_id: children(:wren).id }

    assert_response :not_found
  end

  test "an activity's picture is shown to the family" do
    activities(:painting).picture.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")

    get activity_picture_path(activities(:painting))
    assert_response :success
    assert_equal Mime[:webp], response.media_type

    get activity_picture_path(activities(:forest_school))
    assert_response :not_found
  end

  test "an activity says how often it's been chosen" do
    get activity_path(activities(:painting))

    assert_select ".tag", text: I18n.t("activities.show.chosen", count: 1)
  end

  test "kids' mode lasts as long as the sign-in, not the browser session" do
    post kids_mode_path, params: { child_id: children(:sam).id }

    cookies.delete("_learninglog_session")

    get entries_path
    assert_redirected_to kids_menu_path
  end

  test "changing the password elsewhere signs the device out instead of trapping it" do
    post kids_mode_path, params: { child_id: children(:sam).id }

    users(:alice).update!(password: "a brand new password")

    get kids_menu_path
    assert_redirected_to new_session_path
    get new_session_path
    assert_response :success
  end

  test "removing the child ends kids' mode" do
    child = families(:oaks).children.create!(name: children(:wren).name)
    post kids_mode_path, params: { child_id: child.id }

    child.destroy!

    get entries_path
    assert_response :success
  end

  test "being removed from the family ends kids' mode" do
    post kids_mode_path, params: { child_id: children(:sam).id }

    memberships(:alice_in_oaks).destroy!

    get entries_path
    assert_redirected_to new_family_path
    get new_family_path
    assert_response :success
  end

  test "every other page and action leads back to the kids' menu" do
    post kids_mode_path, params: { child_id: children(:sam).id }

    each_route_outside_kids_mode do |verb, path|
      request = "#{verb.upcase} #{path}"
      process verb, path
      assert_redirected_to kids_menu_path, request
    end
  end

  private
    KIDS_MODE_CONTROLLERS = %w[ kids_menus kids_modes choices surprises activities/pictures rails/health ].freeze

    def each_route_outside_kids_mode
      Rails.application.routes.routes.each do |route|
        controller = route.defaults[:controller]
        next if controller.nil? || controller.start_with?("turbo/") || KIDS_MODE_CONTROLLERS.include?(controller)

        path = route.path.spec.to_s.delete_suffix("(.:format)").gsub(/:(\w+)/) { $1.end_with?("date") ? "2026-11-16" : "1" }
        route.verb.split("|").each { |verb| yield verb.downcase.to_sym, path }
      end
    end
end
