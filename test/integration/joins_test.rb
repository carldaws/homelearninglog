require "test_helper"

class JoinsTest < ActionDispatch::IntegrationTest
  setup do
    @invitation = users(:alice).invitations.create!(children: [ children(:sam), children(:ivy) ])
  end

  test "an invite shows who it's to look after and who sent it" do
    get join_path(@invitation.token)

    assert_select "h1", text: [ children(:ivy).name, children(:sam).name ].to_sentence
    assert_select ".caption", text: users(:alice).first_name
    assert_select "a[href=?]", new_registration_path
  end

  test "creating an account from an invite brings you back to it" do
    get join_path(@invitation.token)

    post registration_path, params: { user: { name: users(:dan).name, email_address: "new@example.com", password: FixturePasswords::PASSWORD } }
    follow_redirect!

    assert_select "a[href=?]", join_url(@invitation.token)
  end

  test "joining from an invite" do
    sign_in_as users(:carol)

    post joins_path, params: { token: @invitation.token }

    assert_redirected_to root_path
    assert_equal [ children(:ivy), children(:sam), children(:wren) ], users(:carol).children.alphabetically
  end

  test "an invite only works once" do
    sign_in_as users(:carol)
    post joins_path, params: { token: @invitation.token }
    delete session_path

    sign_in_as users(:dan)
    post joins_path, params: { token: @invitation.token }

    assert_response :not_found
    assert_empty users(:dan).children
  end

  test "invites expire" do
    travel Invitation::LASTS_FOR + 1.minute

    get join_path(@invitation.token)

    assert_response :not_found
    assert_select "h1", text: I18n.t("joins.expired.title")
  end

  test "an invite stops working for children the inviter no longer looks after" do
    accesses(:alice_for_sam).destroy!
    sign_in_as users(:dan)

    post joins_path, params: { token: @invitation.token }

    assert_equal [ children(:ivy) ], users(:dan).children
  end

  test "grown-ups already looking after the children are sent straight in" do
    sign_in_as users(:bob)

    get join_path(@invitation.token)

    assert_select "a[href=?]", root_path
    assert_select "form[action=?]", joins_path, count: 0
  end
end
