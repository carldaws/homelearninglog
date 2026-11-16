require "test_helper"

class PursuitTest < ActiveSupport::TestCase
  test "finishing a pursuit and picking it back up" do
    travel_to Date.new(2026, 11, 18)
    pursuit = pursuits(:reading)

    pursuit.finish
    assert_not pursuit.current?
    assert_equal Date.new(2026, 11, 18), pursuit.finished_on

    pursuit.pick_up
    assert pursuit.current?
  end

  test "a pursuit can't finish before it started" do
    pursuit = pursuits(:dinosaurs)
    pursuit.finished_on = pursuit.started_on - 1

    assert pursuit.invalid?
    assert pursuit.errors.of_kind?(:finished_on, :greater_than_or_equal_to)
  end

  test "a pursuit's children have to be the family's own" do
    pursuit = pursuits(:reading)
    pursuit.children = [ children(:wren) ]

    assert pursuit.invalid?
    assert pursuit.errors.of_kind?(:children, :outside_the_family)
  end

  test "forms offer current pursuits and any finished ones already chosen" do
    assert_equal [ pursuits(:reading) ], families(:oaks).pursuits_for(entries(:painting)).to_a

    entries(:painting).pursuits << pursuits(:dinosaurs)
    assert_equal [ pursuits(:dinosaurs), pursuits(:reading) ], families(:oaks).pursuits_for(entries(:painting)).to_a
  end

  test "an entry drafted from an activity carries its pursuits" do
    assert_equal [ pursuits(:reading) ], activities(:painting).draft_entry.pursuits.to_a
  end

  test "entries can only be part of the family's own pursuits" do
    entry = entries(:painting)
    entry.pursuits = [ pursuits(:knots) ]

    assert entry.invalid?
    assert entry.errors.of_kind?(:pursuits, :outside_the_family)
  end
end
