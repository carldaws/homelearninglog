class Cancellation < ApplicationRecord
  belongs_to :event

  validates :cancelled_on, presence: true, uniqueness: { scope: :event_id }
end
