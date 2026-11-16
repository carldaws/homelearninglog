class Invitation < ApplicationRecord
  LASTS_FOR = 7.days

  belongs_to :inviter, class_name: "User"
  has_and_belongs_to_many :children

  has_secure_token

  validates :children, presence: true
  validate :inviter_looks_after_the_children

  scope :unexpired, -> { where(created_at: LASTS_FOR.ago..) }

  def offered_children
    children.where(id: inviter.children)
  end

  def joined_by?(user)
    offered_children.where.not(id: user.children).none?
  end

  def accept(user)
    transaction do
      offered_children.each { it.accesses.find_or_create_by!(user:) }
      destroy!
    end
  end

  private
    def inviter_looks_after_the_children
      errors.add(:children, :invalid) if children.any? { it.grown_ups.exclude?(inviter) }
    end
end
