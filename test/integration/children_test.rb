require "test_helper"

class ChildrenTest < ActionDispatch::IntegrationTest
  test "adding a child makes you one of their grown-ups" do
    sign_in_as users(:dan)

    assert_difference -> { users(:dan).children.count } do
      post children_path, params: { child: { name: children(:wren).name } }
    end

    assert_redirected_to child_path(users(:dan).children.last)
  end

  test "a child needs a name" do
    sign_in_as users(:dan)

    assert_no_difference -> { Child.count } do
      post children_path, params: { child: { name: "" } }
    end

    assert_response :unprocessable_content
  end

  test "renaming a child" do
    sign_in_as users(:bob)

    patch child_path(children(:sam)), params: { child: { name: children(:wren).name } }

    assert_redirected_to child_settings_path(children(:sam))
    assert_equal children(:wren).name, children(:sam).reload.name
  end

  test "removing a child, everything recorded about them and all, once their name is typed" do
    sign_in_as users(:alice)

    get new_child_removal_path(children(:sam))
    assert_select "form[action=?]:has(input[name=_method][value=delete])", child_path(children(:sam))

    assert_difference -> { Child.count } => -1, -> { Entry.count } => -2, -> { Event.count } => -2 do
      delete child_path(children(:sam)), params: { confirmation: children(:sam).name }
    end
    assert_redirected_to root_path
  end

  test "a child isn't removed without their name typed" do
    sign_in_as users(:alice)

    assert_no_difference -> { Child.count } do
      delete child_path(children(:sam)), params: { confirmation: children(:ivy).name }
    end

    assert_redirected_to new_child_removal_path(children(:sam))
  end

  test "other people's children are out of reach" do
    sign_in_as users(:alice)

    get edit_child_path(children(:wren))
    assert_response :not_found

    patch child_path(children(:wren)), params: { child: { name: children(:sam).name } }
    assert_response :not_found

    delete child_path(children(:wren)), params: { confirmation: children(:wren).name }
    assert_response :not_found
    assert Child.exists?(children(:wren).id)
  end

  test "the switcher beside the tabs lists your children and adds another" do
    sign_in_as users(:alice)

    get child_log_path(children(:sam))

    assert_select "#child_switcher summary", text: children(:sam).name
    assert_select "#child_switcher a[href=?][aria-current=page]", child_path(children(:sam))
    assert_select "#child_switcher a[href=?]", child_path(children(:ivy))
    assert_select "#child_switcher a[href=?]", new_child_path
  end

  test "the Manage page lists the grown-ups, and links to renaming and removing the child" do
    sign_in_as users(:alice)

    get child_settings_path(children(:ivy))

    assert_select "nav .tab[aria-current=page][href=?]", child_settings_path(children(:ivy))
    assert_select "h1", text: children(:ivy).name
    assert_select "a[href=?]", edit_child_path(children(:ivy))
    assert_select "a[href=?]", new_child_removal_path(children(:ivy))
    assert_select "a[href=?]", new_invitation_path(child_id: children(:ivy).id)
  end
end
