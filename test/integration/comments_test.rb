require "test_helper"

class CommentsTest < ActionDispatch::IntegrationTest
  test "comments show under their entry" do
    sign_in_as users(:alice)

    get child_path(children(:sam))

    assert_select "##{dom_id(entries(:painting))} ##{dom_id(comments(:leaks))}", text: /#{comments(:leaks).body}/
  end

  test "commenting on an entry" do
    sign_in_as users(:alice)
    body = "Let's find a book about ships"

    assert_difference -> { entries(:painting).comments.count } do
      post child_entry_comments_path(children(:sam), entries(:painting)), params: { comment: { body: } }
    end

    assert_redirected_to child_path(children(:sam), through: entries(:painting).happened_on.iso8601, anchor: dom_id(entries(:painting)))
    comment = entries(:painting).comments.last
    assert_equal users(:alice), comment.author
    assert_equal body, comment.body
  end

  test "an empty comment isn't added" do
    sign_in_as users(:alice)

    assert_no_difference -> { Comment.count } do
      post child_entry_comments_path(children(:sam), entries(:painting)), params: { comment: { body: "" } }
    end
  end

  test "editing and deleting your own comment" do
    sign_in_as users(:bob)

    patch child_entry_comment_path(children(:sam), entries(:painting), comments(:leaks)), params: { comment: { body: entries(:moon).what_we_did } }
    assert_equal entries(:moon).what_we_did, comments(:leaks).reload.body

    assert_difference -> { Comment.count }, -1 do
      delete child_entry_comment_path(children(:sam), entries(:painting), comments(:leaks))
    end
  end

  test "other grown-ups' comments can't be changed, and aren't offered for editing" do
    sign_in_as users(:alice)

    get child_path(children(:sam))
    assert_select "a[href=?]", edit_child_entry_comment_path(children(:sam), entries(:painting), comments(:leaks)), count: 0

    patch child_entry_comment_path(children(:sam), entries(:painting), comments(:leaks)), params: { comment: { body: entries(:moon).what_we_did } }
    assert_response :not_found

    delete child_entry_comment_path(children(:sam), entries(:painting), comments(:leaks))
    assert_response :not_found
    assert Comment.exists?(comments(:leaks).id)
  end

  test "other children's entries can't be commented on" do
    sign_in_as users(:alice)

    post child_entry_comments_path(children(:wren), entries(:den)), params: { comment: { body: entries(:moon).what_we_did } }
    assert_response :not_found

    post child_entry_comments_path(children(:sam), entries(:den)), params: { comment: { body: entries(:moon).what_we_did } }
    assert_response :not_found
  end
end
