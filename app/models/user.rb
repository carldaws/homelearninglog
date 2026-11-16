class User < ApplicationRecord
  include Recoverable

  has_secure_password reset_token: false

  before_destroy :remove_children_without_other_grown_ups, prepend: true

  has_many :sessions, dependent: :destroy
  has_many :accesses, dependent: :destroy
  has_many :children, through: :accesses
  has_many :invitations, foreign_key: :inviter_id, inverse_of: :inviter, dependent: :destroy

  attr_accessor :current_password

  normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :password, length: { minimum: 8 }, allow_nil: true
  # has_secure_password ignores a blank password on update rather than rejecting it
  validates :password, presence: true, on: %i[ password_reset password_change ]
  validates :current_password, current_password: true, on: :account_change, if: :will_save_change_to_email_address?
  validates :current_password, current_password: true, on: %i[ password_change recovery_code_renewal account_deletion ]

  after_update :sign_out_everywhere, if: :saved_change_to_password_digest?

  scope :alphabetically, -> { order(:name) }

  def first_name
    name.split.first
  end

  def children_without_other_grown_ups
    children.where.not(id: Access.where.not(user: self).select(:child_id))
  end

  private
    def remove_children_without_other_grown_ups
      children_without_other_grown_ups.each(&:destroy!)
    end

    def sign_out_everywhere
      sessions.destroy_all
    end
end
