require "test_helper"

class FamilyTest < ActiveSupport::TestCase
  test "starting a family makes you a member" do
    family = users(:dan).start_family(name: families(:oaks).name)

    assert family.persisted?
    assert_equal [ users(:dan) ], family.members
  end

  test "a family needs a name" do
    family = users(:dan).start_family(name: "")

    assert_not family.persisted?
    assert family.errors.of_kind?(:name, :blank)
  end

  test "you can't start a family when you're already in one" do
    family = users(:alice).start_family(name: families(:elms).name)

    assert_not family.persisted?
  end

  test "joining a family" do
    membership = families(:oaks).join(users(:dan))

    assert membership.persisted?
    assert_equal families(:oaks), users(:dan).reload.family
  end

  test "each person is in one family" do
    membership = families(:oaks).join(users(:carol))

    assert_not membership.persisted?
    assert membership.errors.of_kind?(:user, :taken)
  end

  test "invitations last a week" do
    token = families(:oaks).generate_token_for(:invitation)

    travel 7.days - 1.minute
    assert_equal families(:oaks), Family.find_by_token_for(:invitation, token)

    travel 2.minutes
    assert_nil Family.find_by_token_for(:invitation, token)
  end
end
