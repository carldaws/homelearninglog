require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "email addresses are stored however they're typed" do
    user = User.create!(name: users(:alice).name, email_address: " New.Person@Example.COM ", password: FixturePasswords::PASSWORD)

    assert_equal User.normalize_value_for(:email_address, user.email_address.upcase), user.email_address
    assert user.email_address.exclude?(" ")
  end

  test "an email address belongs to one account" do
    user = User.new(name: users(:bob).name, email_address: users(:alice).email_address.upcase, password: FixturePasswords::PASSWORD)

    assert_not user.valid?
    assert user.errors.of_kind?(:email_address, :taken)
  end

  test "passwords need at least 8 characters" do
    user = users(:alice)
    user.password = "short"

    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "changing a password needs a password" do
    assert_not users(:alice).valid?(:password_change)
  end

  test "changing a password signs out everywhere" do
    user = users(:alice)
    user.sessions.create!

    user.update!(password: "a brand new password")

    assert_empty user.sessions
  end

  test "a sign-in link stops working once the password changes" do
    user = users(:alice)
    token = user.generate_token_for(:sign_in_link)

    user.update!(password: "a brand new password")

    assert_nil User.find_by_token_for(:sign_in_link, token)
  end

  test "a sign-in link stops working after three days" do
    token = users(:alice).generate_token_for(:sign_in_link)

    travel 3.days + 1.minute

    assert_nil User.find_by_token_for(:sign_in_link, token)
  end

  test "first names come from the full name" do
    assert_equal users(:alice).name.split.first, users(:alice).first_name
  end
end
