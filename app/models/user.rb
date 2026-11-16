class User < ApplicationRecord
  include Recoverable

  has_secure_password reset_token: false

  has_many :sessions, dependent: :destroy
  has_one :membership, dependent: :destroy
  has_one :family, through: :membership

  delegate :id, to: :family, prefix: true, allow_nil: true

  normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :password, length: { minimum: 8 }, allow_nil: true

  after_update :sign_out_everywhere, if: :saved_change_to_password_digest?

  scope :alphabetically, -> { order(:name) }

  def first_name
    name.split.first
  end

  def start_family(attributes)
    Family.new(attributes).tap do |family|
      family.memberships.build(user: self)
      family.save
    end
  end

  private
    def sign_out_everywhere
      sessions.destroy_all
    end
end
