require "test_helper"

class AccessesTest < ActionDispatch::IntegrationTest
  test "a child's grown-ups are listed on their Manage page" do
    sign_in_as users(:alice)

    get child_settings_path(children(:sam))

    assert_select ".row-title", text: users(:alice).name
    assert_select ".row-title", text: users(:bob).name
    assert_select ".row-title", text: users(:carol).name, count: 0
  end

  test "removing another grown-up" do
    sign_in_as users(:alice)

    delete child_access_path(children(:sam), accesses(:bob_for_sam))

    assert_redirected_to child_settings_path(children(:sam))
    assert_not_includes children(:sam).grown_ups.reload, users(:bob)
    assert_includes children(:ivy).grown_ups, users(:bob)
  end

  test "leaving a child" do
    sign_in_as users(:bob)

    delete child_access_path(children(:sam), accesses(:bob_for_sam))

    assert_redirected_to root_path
    get child_path(children(:sam))
    assert_response :not_found
  end

  test "a child's last grown-up can't leave, and isn't offered a way to" do
    sign_in_as users(:carol)

    get child_settings_path(children(:wren))
    assert_select "form[action=?]", child_access_path(children(:wren), accesses(:carol_for_wren)), count: 0

    delete child_access_path(children(:wren), accesses(:carol_for_wren))
    assert_redirected_to child_settings_path(children(:wren))
    assert_includes children(:wren).grown_ups.reload, users(:carol)
  end

  test "other children's grown-ups are out of reach" do
    sign_in_as users(:alice)

    delete child_access_path(children(:wren), accesses(:carol_for_wren))
    assert_response :not_found

    delete child_access_path(children(:sam), accesses(:carol_for_wren))
    assert_response :not_found
  end
end
