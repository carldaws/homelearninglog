require "test_helper"

class FamiliesTest < ActionDispatch::IntegrationTest
  test "people without a family are asked to start one" do
    sign_in_as users(:dan)

    get entries_path

    assert_redirected_to new_family_path
  end

  test "starting a family" do
    sign_in_as users(:dan)

    assert_difference -> { Family.count } do
      post family_path, params: { family: { name: families(:oaks).name } }
    end

    assert_redirected_to new_family_child_path
    assert_equal families(:oaks).name, users(:dan).reload.family.name
  end

  test "the family page shows its children and grown-ups" do
    sign_in_as users(:alice)

    get family_path

    assert_select "h1", text: families(:oaks).name
    assert_select ".row-title", text: children(:sam).name
    assert_select ".row-title", text: users(:bob).name
    assert_select ".row-title", text: children(:wren).name, count: 0
  end

  test "people in a family can't start another" do
    sign_in_as users(:alice)

    get new_family_path

    assert_redirected_to family_path
  end

  test "renaming the family" do
    sign_in_as users(:bob)

    patch family_path, params: { family: { name: families(:elms).name } }

    assert_redirected_to family_path
    assert_equal families(:elms).name, families(:oaks).reload.name
  end

  test "adding a child" do
    sign_in_as users(:alice)

    assert_difference -> { families(:oaks).children.count } do
      post family_children_path, params: { child: { name: children(:wren).name } }
    end

    assert_redirected_to family_path
  end

  test "a child needs a name" do
    sign_in_as users(:alice)

    post family_children_path, params: { child: { name: "" } }

    assert_response :unprocessable_content
  end

  test "renaming a child" do
    sign_in_as users(:alice)

    patch family_child_path(children(:sam)), params: { child: { name: children(:wren).name } }

    assert_equal children(:wren).name, children(:sam).reload.name
  end

  test "removing a child" do
    sign_in_as users(:alice)
    child = families(:oaks).children.create!(name: children(:wren).name)

    assert_difference -> { families(:oaks).children.count }, -1 do
      delete family_child_path(child)
    end
  end

  test "children in the log can't be removed" do
    sign_in_as users(:alice)

    assert_no_difference -> { families(:oaks).children.count } do
      delete family_child_path(children(:sam))
    end

    assert_redirected_to edit_family_child_path(children(:sam))
  end

  test "other families' children are out of reach" do
    sign_in_as users(:alice)

    get edit_family_child_path(children(:wren))
    assert_response :not_found

    delete family_child_path(children(:wren))
    assert_response :not_found
    assert Child.exists?(children(:wren).id)
  end

  test "removing another grown-up" do
    sign_in_as users(:alice)

    delete family_membership_path(memberships(:bob_in_oaks))

    assert_redirected_to family_path
    assert_nil users(:bob).reload.family
  end

  test "leaving the family" do
    sign_in_as users(:bob)

    delete family_membership_path(memberships(:bob_in_oaks))
    follow_redirect!

    assert_redirected_to new_family_path
    assert_nil users(:bob).reload.family
  end

  test "the last grown-up can't leave" do
    sign_in_as users(:carol)

    delete family_membership_path(memberships(:carol_in_elms))

    assert_redirected_to family_path
    assert_equal families(:elms), users(:carol).reload.family
  end

  test "other families' grown-ups are out of reach" do
    sign_in_as users(:alice)

    delete family_membership_path(memberships(:carol_in_elms))

    assert_response :not_found
  end

  test "making a sign-in link for another grown-up" do
    sign_in_as users(:alice)

    get family_membership_sign_in_link_path(memberships(:bob_in_oaks))

    assert_response :success
    link = css_select("[data-share-url-value]").first["data-share-url-value"]
    token = Rails.application.routes.recognize_path(link)[:token]
    assert_equal users(:bob), User.find_by_token_for(:sign_in_link, token)
  end

  test "you can't make a sign-in link for someone in another family" do
    sign_in_as users(:alice)

    get family_membership_sign_in_link_path(memberships(:carol_in_elms))

    assert_response :not_found
  end

  test "a removed grown-up's sign-in links stop working" do
    sign_in_as users(:bob)
    get family_membership_sign_in_link_path(memberships(:alice_in_oaks))
    link = css_select("[data-share-url-value]").first["data-share-url-value"]
    delete session_path

    sign_in_as users(:alice)
    delete family_membership_path(memberships(:bob_in_oaks))
    delete session_path

    get link
    assert_response :not_found
  end

  test "the last grown-up isn't offered a way to leave" do
    sign_in_as users(:carol)

    get family_path

    assert_select "form[action=?]", family_membership_path(memberships(:carol_in_elms)), count: 0
  end

  test "children on the calendar can't be removed" do
    sign_in_as users(:alice)
    entries(:moon).destroy!

    get edit_family_child_path(children(:ivy))
    assert_select "form[action=?]:has(input[name=_method][value=delete])", family_child_path(children(:ivy)), count: 0

    assert_no_difference -> { families(:oaks).children.count } do
      delete family_child_path(children(:ivy))
    end
  end

  test "children in the log aren't offered for removal" do
    sign_in_as users(:alice)

    get edit_family_child_path(children(:sam))

    assert_select "form[action=?]:has(input[name=_method][value=delete])", family_child_path(children(:sam)), count: 0
  end
end
