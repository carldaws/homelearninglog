class Comment < ApplicationRecord
  belongs_to :entry
  belongs_to :author, class_name: "User", optional: true

  delegate :first_name, to: :author, prefix: true, allow_nil: true

  validates :author, presence: true, on: :create
  validates :body, presence: true
end
