require "test_helper"

class WeekTest < ActiveSupport::TestCase
  test "a week runs Monday to Sunday" do
    week = families(:oaks).week(containing: "2026-11-18")

    assert_equal Date.new(2026, 11, 16)..Date.new(2026, 11, 22), week.dates
    assert_equal Date.new(2026, 11, 9), week.previous
    assert_equal Date.new(2026, 11, 23), week.following
  end

  test "each day has its events" do
    days = families(:oaks).week(containing: "2026-11-18").days

    assert_equal 7, days.size
    assert_equal [ events(:art_class) ], days[Date.new(2026, 11, 16)].map(&:event)
    assert_equal [ events(:visit) ], days[Date.new(2026, 11, 21)].map(&:event)
    assert_empty days[Date.new(2026, 11, 17)]
  end

  test "nonsense weeks show this week" do
    assert families(:oaks).week(containing: "not a date").current?
    assert families(:oaks).week(containing: [ "2026-11-18" ]).current?
  end

  test "time is added up for each grown-up" do
    travel_to Date.new(2026, 11, 18)
    families(:oaks).entries.destroy_all
    log users(:alice), Date.new(2026, 11, 16), 60
    log users(:alice), Date.new(2026, 11, 17), 30
    log users(:bob), Date.new(2026, 11, 17), 45
    log users(:bob), Date.new(2026, 11, 9), 120

    week = families(:oaks).week

    assert_equal({ users(:alice) => 90, users(:bob) => 45 }, week.minutes_by_grown_up)
    assert_equal 135, week.minutes
    assert_equal 2, week.days_logged
  end

  test "each pursuit active that week shows how much went into it, even if nothing did" do
    travel_to Date.new(2026, 11, 18)
    families(:oaks).entries.destroy_all
    log users(:alice), Date.new(2026, 11, 16), 60, [ pursuits(:reading) ]
    log users(:bob), Date.new(2026, 11, 17), nil, [ pursuits(:reading) ]
    idle = families(:oaks).pursuits.create!(name: "Knitting", started_on: Date.new(2026, 11, 1))

    tallies = families(:oaks).week.pursuit_tallies.index_by(&:pursuit)

    assert_equal 2, tallies[pursuits(:reading)].entry_count
    assert_equal 60, tallies[pursuits(:reading)].minutes
    assert_equal 0, tallies[idle].entry_count
    assert_not tallies.key?(pursuits(:dinosaurs))
  end

  test "past weeks show the pursuits that were going on then" do
    tallies = families(:oaks).week(containing: "2026-09-02").pursuit_tallies.map(&:pursuit)

    assert_includes tallies, pursuits(:dinosaurs)
    assert_not_includes tallies, pursuits(:reading)
  end

  test "the week's choices are listed" do
    travel_to Date.new(2026, 11, 18)
    children(:ivy).choose(activities(:painting))
    travel_to(Date.new(2026, 11, 25)) { children(:ivy).choose(activities(:painting)) }

    assert_equal 1, families(:oaks).week.choices.count { it.child == children(:ivy) }
  end

  test "each week has its own reflection" do
    travel_to Date.new(2026, 11, 18)
    notes = "Reading clicked this week"
    families(:oaks).week.reflection.update!(notes:)

    assert_equal notes, families(:oaks).week.reflection.notes
    assert families(:oaks).week(containing: "2026-11-25").reflection.new_record?
  end

  private
    def log(author, date, minutes, pursuits = [])
      families(:oaks).entries.create!(author:, happened_on: date, minutes:, pursuits:, notes: "Something happened", children: [ children(:sam) ])
    end
end
