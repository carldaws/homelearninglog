class Child < ApplicationRecord
  belongs_to :family
  has_and_belongs_to_many :entries

  validates :name, presence: true

  scope :alphabetically, -> { order(:name) }

  before_destroy :keep_children_with_entries

  private
    def keep_children_with_entries
      if entries.exists?
        errors.add(:base, :has_entries, name:)
        throw :abort
      end
    end
end
