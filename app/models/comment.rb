class Comment < ApplicationRecord
  belongs_to :entry
  belongs_to :author, class_name: "User"

  validates :body, presence: true
end
