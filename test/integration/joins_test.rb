require "test_helper"

class JoinsTest < ActionDispatch::IntegrationTest
  setup do
    @token = families(:oaks).generate_token_for(:invitation)
  end

  test "an invite shows who you'd be joining" do
    get join_path(@token)

    assert_select "h1", text: families(:oaks).name
    assert_select "a[href=?]", new_registration_path
  end

  test "creating an account from an invite brings you back to it" do
    get join_path(@token)

    post registration_path, params: { user: { name: users(:dan).name, email_address: "new@example.com", password: FixturePasswords::PASSWORD } }

    assert_redirected_to join_url(@token)
  end

  test "joining from an invite" do
    sign_in_as users(:dan)

    post joins_path, params: { token: @token }

    assert_redirected_to root_path
    assert_equal families(:oaks), users(:dan).reload.family
  end

  test "people already in a family can't join another" do
    sign_in_as users(:carol)

    post joins_path, params: { token: @token }

    assert_redirected_to join_path(@token)
    assert_equal families(:elms), users(:carol).reload.family
  end

  test "invites expire" do
    travel 8.days

    get join_path(@token)

    assert_response :not_found
    assert_select "h1", text: I18n.t("joins.expired.heading")
  end

  test "an invite link can be made by anyone in the family" do
    sign_in_as users(:bob)

    get family_invitation_path

    link = css_select("[data-share-url-value]").first["data-share-url-value"]
    token = Rails.application.routes.recognize_path(link)[:token]
    assert_equal families(:oaks), Family.find_by_token_for(:invitation, token)
  end
end
