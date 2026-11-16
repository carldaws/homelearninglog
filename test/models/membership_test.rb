require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "a grown-up can leave while someone else stays" do
    assert memberships(:bob_in_oaks).destroy
    assert_equal [ users(:alice) ], families(:oaks).members.reload
  end

  test "the last grown-up can't leave" do
    membership = memberships(:carol_in_elms)

    assert_not membership.destroy
    assert membership.errors.of_kind?(:base, :last_member)
    assert families(:elms).memberships.exists?(membership.id)
  end
end
