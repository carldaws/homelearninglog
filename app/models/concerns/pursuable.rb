module Pursuable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :pursuits
    validates :pursuits, same_family: true
  end

  def pursuit_choices
    family.pursuits.current.or(family.pursuits.where(id: pursuit_ids)).alphabetically
  end
end
