class Membership < ApplicationRecord
  belongs_to :family
  belongs_to :user

  validates :user, uniqueness: { message: :already_in_a_family }

  before_destroy :keep_someone_in_the_family, unless: :destroyed_by_association

  private
    def keep_someone_in_the_family
      if family.memberships.excluding(self).none?
        errors.add(:base, :last_member)
        throw :abort
      end
    end
end
