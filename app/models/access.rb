class Access < ApplicationRecord
  belongs_to :child
  belongs_to :user

  has_secure_token :calendar_token

  validates :user, uniqueness: { scope: :child }

  scope :alphabetically, -> { eager_load(:user).merge(User.alphabetically) }

  before_destroy :keep_a_grown_up
  after_destroy :leave_events

  private
    def keep_a_grown_up
      child.lock!

      if child.accesses.excluding(self).none?
        errors.add(:base, :last_grown_up, name: child.name)
        throw :abort
      end
    end

    def leave_events
      child.events.where(grown_up: user).update_all(grown_up_id: nil)
    end
end
