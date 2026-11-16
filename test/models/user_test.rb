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

  test "resetting a password needs a password" do
    assert_not users(:alice).valid?(:password_reset)
  end

  test "changing a password signs out everywhere" do
    user = users(:alice)
    user.sessions.create!

    user.update!(password: "a brand new password")

    assert_empty user.sessions
  end

  test "first names come from the full name" do
    assert_equal users(:alice).name.split.first, users(:alice).first_name
  end

  test "a new account gets a recovery code" do
    user = User.create!(name: users(:alice).name, email_address: "new@example.com", password: FixturePasswords::PASSWORD)

    assert_equal User::RECOVERY_CODE_LENGTH, user.recovery_code.length
    assert_equal user, User.authenticate_by_recovery_code(email_address: user.email_address, recovery_code: user.recovery_code)
  end

  test "recovery codes can be typed in lower case, with spaces and dashes" do
    typed = FixturePasswords::RECOVERY_CODE.downcase.scan(/.{4}/).join(" - ")

    assert_equal users(:alice), User.authenticate_by_recovery_code(email_address: users(:alice).email_address, recovery_code: typed)
  end

  test "resetting a password replaces the recovery code" do
    user = users(:alice)

    user.password = "a brand new password"
    assert user.save(context: :password_reset)

    assert user.reload.authenticate_password("a brand new password")
    assert_nil User.authenticate_by_recovery_code(email_address: user.email_address, recovery_code: FixturePasswords::RECOVERY_CODE)
    assert_equal user, User.authenticate_by_recovery_code(email_address: user.email_address, recovery_code: user.recovery_code)
  end

  test "a failed reset keeps the recovery code" do
    user = users(:alice)

    user.password = "short"
    assert_not user.save(context: :password_reset)

    assert_equal user, User.authenticate_by_recovery_code(email_address: user.email_address, recovery_code: FixturePasswords::RECOVERY_CODE)
  end

  test "deleting someone removes the children only they look after, with everything recorded about them" do
    wren, den = children(:wren), entries(:den)

    users(:carol).destroy!

    assert_not Child.exists?(wren.id)
    assert_not Entry.exists?(den.id)
  end

  test "deleting someone keeps what they wrote in other children's logs, without their name" do
    users(:bob).destroy!

    assert Child.exists?(children(:sam).id)
    assert_nil entries(:moon).reload.author
    assert_nil comments(:leaks).reload.author
    assert_nil events(:art_class).reload.grown_up
    assert_equal [ users(:alice) ], children(:sam).grown_ups.reload
  end
end
