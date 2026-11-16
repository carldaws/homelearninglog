require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  test "an invitation is to at least one child" do
    invitation = users(:alice).invitations.build

    assert_not invitation.valid?
    assert invitation.errors.of_kind?(:children, :blank)
  end

  test "an invitation can only be to children the inviter looks after" do
    invitation = users(:alice).invitations.build(children: [ children(:sam), children(:wren) ])

    assert_not invitation.valid?
    assert invitation.errors.of_kind?(:children, :invalid)
  end

  test "accepting links the grown-up to every child and uses the invitation up" do
    invitation = users(:alice).invitations.create!(children: [ children(:sam), children(:ivy) ])

    invitation.accept(users(:dan))

    assert_equal [ children(:ivy), children(:sam) ], users(:dan).children.alphabetically
    assert invitation.destroyed?
  end

  test "accepting skips children the grown-up already looks after" do
    invitation = users(:alice).invitations.create!(children: [ children(:sam), children(:ivy) ])
    accesses(:bob_for_ivy).destroy!

    invitation.accept(users(:bob))

    assert_equal [ children(:ivy), children(:sam) ], users(:bob).children.alphabetically
  end

  test "invitations last a week" do
    invitation = users(:alice).invitations.create!(children: [ children(:sam) ])

    travel Invitation::LASTS_FOR - 1.minute
    assert_includes Invitation.unexpired, invitation

    travel 2.minutes
    assert_not_includes Invitation.unexpired, invitation
  end
end
