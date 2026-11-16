require "test_helper"

class SignInLinksTest < ActionDispatch::IntegrationTest
  setup do
    @token = users(:alice).generate_token_for(:sign_in_link)
  end

  test "a sign-in link lets you choose a new password" do
    get edit_password_path(@token)

    assert_response :success
    assert_select "#user_email_address[readonly][value=?]", users(:alice).email_address
  end

  test "choosing a new password signs you in" do
    patch password_path(@token), params: { user: { password: "a brand new password" } }

    assert_redirected_to entries_url
    assert users(:alice).reload.authenticate_password("a brand new password")
  end

  test "a new password can't be blank" do
    patch password_path(@token), params: { user: { password: "" } }

    assert_response :unprocessable_content
    assert_not_signed_in
  end

  test "a sign-in link only works once" do
    patch password_path(@token), params: { user: { password: "a brand new password" } }
    delete session_path

    get edit_password_path(@token)

    assert_response :not_found
    assert_select "h1", text: I18n.t("passwords.expired.heading")
  end

  test "a made-up link doesn't work" do
    get edit_password_path("made-up")

    assert_response :not_found
  end
end
