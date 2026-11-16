require "test_helper"

class RegistrationsTest < ActionDispatch::IntegrationTest
  test "creating an account signs you in" do
    assert_difference -> { User.count } do
      post registration_path, params: { user: { name: users(:alice).name, email_address: "new@example.com", password: FixturePasswords::PASSWORD } }
    end

    assert_redirected_to entries_url
    assert_signed_in
  end

  test "an account needs a name, an email address and a password" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { name: "", email_address: "", password: "" } }
    end

    assert_response :unprocessable_content
    assert_select "[role=alert] p", count: 3
  end

  test "an email address can only be used once" do
    post registration_path, params: { user: { name: users(:bob).name, email_address: users(:alice).email_address, password: FixturePasswords::PASSWORD } }

    assert_response :unprocessable_content
  end
end
