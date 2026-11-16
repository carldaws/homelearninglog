require "test_helper"

class InvitationsTest < ActionDispatch::IntegrationTest
  test "inviting a grown-up to a child" do
    sign_in_as users(:carol)

    assert_difference -> { Invitation.count } do
      post invitations_path, params: { invitation: { child_ids: [ children(:wren).id ] } }
    end

    invitation = Invitation.last
    assert_redirected_to invitation_path(invitation)
    assert_equal [ children(:wren) ], invitation.children
    follow_redirect!
    assert_select "[data-share-url-value=?]", join_url(invitation.token)
  end

  test "one invitation can be to several children" do
    sign_in_as users(:alice)

    get new_invitation_path(child_id: children(:sam).id)
    assert_select "input[type=checkbox][value=?][checked]", children(:sam).id.to_s
    assert_select "input[type=checkbox][value=?]:not([checked])", children(:ivy).id.to_s

    post invitations_path, params: { invitation: { child_ids: [ children(:sam).id, children(:ivy).id ] } }

    assert_equal [ children(:ivy), children(:sam) ], Invitation.last.children.alphabetically
  end

  test "you can only invite people to children you look after" do
    sign_in_as users(:alice)

    assert_no_difference -> { Invitation.count } do
      post invitations_path, params: { invitation: { child_ids: [ children(:wren).id ] } }
    end

    assert_response :unprocessable_content
  end

  test "other people's invitations are out of reach" do
    invitation = users(:carol).invitations.create!(children: [ children(:wren) ])
    sign_in_as users(:alice)

    get invitation_path(invitation)

    assert_response :not_found
  end
end
