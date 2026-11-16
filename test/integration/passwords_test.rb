require "test_helper"

class PasswordsTest < ActionDispatch::IntegrationTest
  test "a recovery code lets you choose a new password and signs you in" do
    reset users(:alice), recovery_code: FixturePasswords::RECOVERY_CODE

    assert_redirected_to recovery_code_path
    assert users(:alice).reload.authenticate_password("a brand new password")
    assert_signed_in
  end

  test "you're shown your next recovery code, and it works" do
    reset users(:alice), recovery_code: FixturePasswords::RECOVERY_CODE
    follow_redirect!
    recovery_code = css_select(".select-all").first.text
    delete session_path

    reset users(:alice), recovery_code:, password: "another new password"

    assert users(:alice).reload.authenticate_password("another new password")
  end

  test "a recovery code only works once" do
    reset users(:alice), recovery_code: FixturePasswords::RECOVERY_CODE
    delete session_path

    reset users(:alice), recovery_code: FixturePasswords::RECOVERY_CODE, password: "another new password"

    assert_response :unprocessable_content
    assert_not users(:alice).reload.authenticate_password("another new password")
  end

  test "a wrong recovery code doesn't change the password" do
    reset users(:alice), recovery_code: FixturePasswords::RECOVERY_CODE.reverse

    assert_response :unprocessable_content
    assert_select "[role=alert]", text: I18n.t("passwords.create.invalid")
    assert_not users(:alice).reload.authenticate_password("a brand new password")
    assert_not_signed_in
  end

  test "a new password still has to be long enough" do
    reset users(:alice), recovery_code: FixturePasswords::RECOVERY_CODE, password: "short"

    assert_response :unprocessable_content
    assert_not_signed_in
  end

  test "the recovery code page is only shown once" do
    reset users(:alice), recovery_code: FixturePasswords::RECOVERY_CODE
    follow_redirect!

    get recovery_code_path

    assert_redirected_to root_path
  end

  test "signed-in people aren't asked for a recovery code" do
    sign_in_as users(:alice)

    get new_password_path

    assert_redirected_to root_path
  end

  private
    def reset(user, recovery_code:, password: "a brand new password")
      post password_path, params: { email_address: user.email_address, recovery_code:, password: }
    end
end
