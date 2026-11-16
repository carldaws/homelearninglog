class Child < ApplicationRecord
  belongs_to :family
  has_and_belongs_to_many :entries
  has_and_belongs_to_many :events
  has_and_belongs_to_many :pursuits
  has_many :choices, dependent: :destroy

  validates :name, presence: true

  scope :alphabetically, -> { order(:name) }

  before_destroy :keep_children_in_use

  def choose(activity)
    choices.create!(activity:)
  end

  def removable?
    entries.none? && events.none? && pursuits.none?
  end

  private
    def keep_children_in_use
      unless removable?
        errors.add(:base, :in_use, name:)
        throw :abort
      end
    end
end
