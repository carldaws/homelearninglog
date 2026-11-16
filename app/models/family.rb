class Family < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :children, dependent: :destroy
  has_many :choices, through: :children
  has_many :entries, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :pursuits, dependent: :destroy
  has_many :reflections, dependent: :destroy

  has_secure_token :invitation_code
  has_secure_token :calendar_token

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

  def draft_pursuit
    pursuits.build(started_on: Date.current, children:)
  end

  def draft_event(on: nil, **attributes)
    events.build(starts_on: ActiveModel::Type::Date.new.cast(on) || Date.current, children:, **attributes)
  end

  def draft_entry(**attributes)
    entries.build(happened_on: Date.current, children:, **attributes)
  end

  def log(through: nil)
    Log.new(self, through:)
  end

  def week(containing: nil)
    Week.new(self, containing:)
  end

  def occurrences_between(dates)
    events.between(dates).includes(:cancellations, :children, :grown_up)
      .flat_map { it.occurrences_between(dates) }
      .sort_by { [ it.date, it.all_day? ? 0 : 1, it.start_time.to_i ] }
  end
end
