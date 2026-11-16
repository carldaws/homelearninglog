require "test_helper"

class ChoiceTest < ActiveSupport::TestCase
  test "a child chooses from their own family's activities" do
    assert children(:ivy).choose(activities(:painting)).persisted?

    assert_raises(ActiveRecord::RecordInvalid) { children(:ivy).choose(activities(:dens)) }
  end
end
