class Membership < ApplicationRecord
  belongs_to :family
  belongs_to :user

  validates :user, uniqueness: true

  scope :alphabetically, -> { includes(:user).merge(User.alphabetically).references(:user) }

  before_destroy :keep_someone_in_the_family
  after_destroy :cancel_family_invitations, :leave_family_events

  private
    def cancel_family_invitations
      family.cancel_invitations
    end

    def leave_family_events
      family.events.where(grown_up: user).update_all(grown_up_id: nil)
    end

    def keep_someone_in_the_family
      if family.memberships.excluding(self).none?
        errors.add(:base, :last_member)
        throw :abort
      end
    end
end
