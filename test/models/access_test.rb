require "test_helper"

class AccessTest < ActiveSupport::TestCase
  test "a grown-up can leave while someone else stays" do
    assert accesses(:bob_for_sam).destroy
    assert_equal [ users(:alice) ], children(:sam).grown_ups.reload
  end

  test "a grown-up who leaves is taken off the child's events" do
    accesses(:bob_for_sam).destroy!

    assert_nil events(:art_class).reload.grown_up
    assert events(:art_class).valid?
  end

  test "a child's last grown-up can't leave" do
    access = accesses(:carol_for_wren)

    assert_not access.destroy
    assert access.errors.of_kind?(:base, :last_grown_up)
    assert children(:wren).accesses.exists?(access.id)
  end

  test "each grown-up is linked to a child once" do
    access = children(:sam).accesses.build(user: users(:alice))

    assert_not access.valid?
    assert access.errors.of_kind?(:user, :taken)
  end
end
