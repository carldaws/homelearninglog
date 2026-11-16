require "test_helper"

class WeekReviewTest < ActiveSupport::TestCase
  setup do
    travel_to Date.new(2026, 11, 18)
    @family = families(:oaks)
    @family.entries.destroy_all
    @log = ->(author, date, minutes, pursuits = []) do
      @family.entries.create!(author:, happened_on: date, minutes:, pursuits:, notes: activities(:painting).notes, children: [ children(:sam) ])
    end
  end

  test "time is added up for each grown-up" do
    @log.(users(:alice), Date.new(2026, 11, 16), 60)
    @log.(users(:alice), Date.new(2026, 11, 17), 30)
    @log.(users(:bob), Date.new(2026, 11, 17), 45)
    @log.(users(:bob), Date.new(2026, 11, 9), 120)

    week = @family.week

    assert_equal({ users(:alice) => 90, users(:bob) => 45 }, week.minutes_by_grown_up)
    assert_equal 135, week.minutes
    assert_equal 2, week.days_logged
  end

  test "each current pursuit shows how much went into it, even if nothing did" do
    @log.(users(:alice), Date.new(2026, 11, 16), 60, [ pursuits(:reading) ])
    @log.(users(:bob), Date.new(2026, 11, 17), nil, [ pursuits(:reading) ])
    @family.pursuits.create!(name: pursuits(:knots).name, started_on: Date.new(2026, 11, 1))

    tallies = @family.week.pursuit_tallies.index_by(&:pursuit)

    assert_equal 2, tallies[pursuits(:reading)].entries
    assert_equal 60, tallies[pursuits(:reading)].minutes
    assert_equal 0, tallies.values.find { it.pursuit.name == pursuits(:knots).name }.entries
    assert_not tallies.key?(pursuits(:dinosaurs))
  end

  test "the week's choices are listed" do
    children(:ivy).choose(activities(:painting))
    travel_to Date.new(2026, 11, 25) do
      children(:ivy).choose(activities(:painting))
    end

    assert_equal 1, @family.week.choices.count { it.child == children(:ivy) }
  end

  test "each week has its own reflection" do
    @family.week.reflection.update!(notes: pursuits(:reading).name)

    assert_equal pursuits(:reading).name, @family.week.reflection.notes
    assert @family.week(containing: Date.new(2026, 11, 25)).reflection.new_record?
  end
end
