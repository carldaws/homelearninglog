class Family < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :children, dependent: :destroy
  has_many :entries, dependent: :destroy

  has_secure_token :invitation_code

  generates_token_for :invitation, expires_in: 7.days do
    invitation_code
  end

  validates :name, presence: true

  def join(user)
    memberships.create(user:)
  end

  def cancel_invitations
    regenerate_invitation_code
  end

  def log(through: nil)
    Log.new(self, through:)
  end

  def members_by_name
    members.order(:name)
  end

  def children_by_name
    children.order(:name)
  end
end
