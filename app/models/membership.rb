class Membership < ApplicationRecord
  belongs_to :family
  belongs_to :user

  validates :user, uniqueness: true

  scope :alphabetically, -> { includes(:user).merge(User.alphabetically).references(:user) }

  before_destroy :keep_someone_in_the_family
  after_destroy -> { family.cancel_invitations }

  private
    def keep_someone_in_the_family
      if family.memberships.excluding(self).none?
        errors.add(:base, :last_member)
        throw :abort
      end
    end
end
