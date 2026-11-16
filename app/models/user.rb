class User < ApplicationRecord
  include Recoverable

  has_secure_password reset_token: false

  has_many :sessions, dependent: :destroy
  has_many :accesses, dependent: :destroy
  has_many :children, through: :accesses
  has_many :invitations, foreign_key: :inviter_id, inverse_of: :inviter, dependent: :destroy

  normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :password, length: { minimum: 8 }, allow_nil: true

  after_update :sign_out_everywhere, if: :saved_change_to_password_digest?

  scope :alphabetically, -> { order(:name) }

  def first_name
    name.split.first
  end

  private
    def sign_out_everywhere
      sessions.destroy_all
    end
end
