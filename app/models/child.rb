class Child < ApplicationRecord
  belongs_to :family
  has_and_belongs_to_many :entries
  has_and_belongs_to_many :events

  validates :name, presence: true

  scope :alphabetically, -> { order(:name) }

  before_destroy :keep_children_in_use

  def removable?
    entries.none? && events.none?
  end

  private
    def keep_children_in_use
      unless removable?
        errors.add(:base, :in_use, name:)
        throw :abort
      end
    end
end
