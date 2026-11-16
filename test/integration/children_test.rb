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

    assert_redirected_to child_path(children(:sam))
    assert_equal children(:wren).name, children(:sam).reload.name
  end

  test "removing a child with nothing recorded" do
    sign_in_as users(:alice)

    assert_difference -> { users(:alice).children.count }, -1 do
      delete child_path(children(:ivy))
    end

    assert_redirected_to root_path
  end

  test "children with things recorded can't be removed, and aren't offered for removal" do
    sign_in_as users(:alice)

    get edit_child_path(children(:sam))
    assert_select "form[action=?]:has(input[name=_method][value=delete])", child_path(children(:sam)), count: 0

    assert_no_difference -> { Child.count } do
      delete child_path(children(:sam))
    end
    assert_redirected_to edit_child_path(children(:sam))
  end

  test "other people's children are out of reach" do
    sign_in_as users(:alice)

    get edit_child_path(children(:wren))
    assert_response :not_found

    patch child_path(children(:wren)), params: { child: { name: children(:sam).name } }
    assert_response :not_found

    delete child_path(children(:wren))
    assert_response :not_found
    assert Child.exists?(children(:wren).id)
  end

  test "the menu switches between children when there's more than one" do
    sign_in_as users(:alice)
    get child_path(children(:sam))
    assert_select ".menu a[href=?]", child_path(children(:ivy))

    delete session_path
    sign_in_as users(:carol)
    get child_path(children(:wren))
    assert_select ".menu a[href=?]", child_path(children(:wren)), count: 0
  end
end
