class Session < ApplicationRecord
  belongs_to :user
  belongs_to :choosing_child, class_name: "Child", optional: true

  def kids_mode?
    choosing_child.present? && choosing_child.family_id == user.family_id
  end
end
