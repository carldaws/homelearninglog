require "test_helper"

class AccountsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  test "the header links to your account, which shows your details and signs you out" do
    get account_path

    assert_select "header a[href=?]", account_path
    assert_select "dd", text: users(:alice).name
    assert_select "dd", text: users(:alice).email_address
    assert_select "form[action=?]", session_path
  end

  test "changing your name needs no password" do
    patch account_path, params: { user: { name: users(:bob).name, email_address: users(:alice).email_address } }

    assert_redirected_to account_path
    assert_equal users(:bob).name, users(:alice).reload.name
  end

  test "changing your email address needs your current password" do
    email_address = "alice.new@example.com"

    patch account_path, params: { user: { name: users(:alice).name, email_address:, current_password: "not my password" } }
    assert_response :unprocessable_content
    assert_not_equal email_address, users(:alice).reload.email_address

    patch account_path, params: { user: { name: users(:alice).name, email_address:, current_password: FixturePasswords::PASSWORD } }
    assert_redirected_to account_path
    assert_equal email_address, users(:alice).reload.email_address
  end

  test "an email address someone else uses can't be taken" do
    patch account_path, params: { user: { name: users(:alice).name, email_address: users(:bob).email_address, current_password: FixturePasswords::PASSWORD } }

    assert_response :unprocessable_content
  end
end
