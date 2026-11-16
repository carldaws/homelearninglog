require "test_helper"

class SignInTest < ActionDispatch::IntegrationTest
  test "signed-out people can create an account or sign in" do
    get root_path

    assert_select "main a[href=?]", new_registration_path
    assert_select "main a[href=?]", new_session_path
  end

  test "signing in" do
    sign_in_as users(:alice)

    assert_redirected_to root_url
    assert_signed_in
  end

  test "signing in however the email address is typed" do
    post session_path, params: { email_address: " #{users(:alice).email_address.upcase} ", password: FixturePasswords::PASSWORD }

    assert_redirected_to root_url
  end

  test "a wrong password doesn't sign you in" do
    sign_in_as users(:alice), password: "wrong password"

    assert_response :unprocessable_content
    assert_select "#email_address[value=?]", users(:alice).email_address
    assert_select "[role=alert]", text: I18n.t("sessions.create.invalid")
    assert_not_signed_in
  end

  test "an unknown email address gets the same answer as a wrong password" do
    post session_path, params: { email_address: "nobody@example.com", password: FixturePasswords::PASSWORD }

    assert_response :unprocessable_content
    assert_select "[role=alert]", text: I18n.t("sessions.create.invalid")
  end

  test "passwords can't be guessed in bulk" do
    post session_path, params: { email_address: users(:alice).email_address, password: [ "one", FixturePasswords::PASSWORD ] }

    assert_response :bad_request
    assert_not_signed_in
  end

  test "guessing passwords is rate limited by email address" do
    10.times { |n| sign_in_as users(:alice), password: "wrong", headers: { "REMOTE_ADDR" => "10.0.0.#{n}" } }

    sign_in_as users(:alice), headers: { "REMOTE_ADDR" => "10.0.0.99" }

    assert_redirected_to new_session_path
    assert_equal I18n.t("sessions.create.rate_limited"), flash[:alert]
  end

  test "signing out" do
    sign_in_as users(:alice)

    delete session_path

    assert_redirected_to root_path
    assert_not_signed_in
  end

  test "signed-in people aren't asked to sign in again" do
    sign_in_as users(:alice)

    get new_session_path

    assert_redirected_to root_path
  end

  test "signed-in people go straight to their first child's log" do
    sign_in_as users(:alice)

    get root_path

    assert_redirected_to child_path(children(:ivy))
  end

  test "people looking after no children are asked to add one" do
    sign_in_as users(:dan)

    get root_path

    assert_redirected_to new_child_path
  end

  test "signing in returns you to where you were going" do
    get new_child_entry_path(children(:sam))

    sign_in_as users(:alice)

    assert_redirected_to new_child_entry_url(children(:sam))
  end
end
