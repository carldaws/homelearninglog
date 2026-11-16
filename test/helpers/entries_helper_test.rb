require "test_helper"

class EntriesHelperTest < ActionView::TestCase
  test "durations in hours and minutes" do
    assert_equal I18n.t("entries.duration.minutes", count: 45), duration(45)
    assert_equal I18n.t("entries.duration.hours", count: 1), duration(60)
    assert_equal [ I18n.t("entries.duration.hours", count: 2), I18n.t("entries.duration.minutes", count: 30) ].join(" "), duration(150)
  end

  test "time options include an unusual time already chosen" do
    assert_includes duration_options(75).map(&:last), 75
    assert_equal Entry::SUGGESTED_MINUTES, duration_options(nil).map(&:last)
  end

  test "days are named relative to today" do
    travel_to Date.new(2026, 1, 2)

    assert_equal I18n.t("entries.days.today"), day_heading(Date.current)
    assert_equal I18n.t("entries.days.yesterday"), day_heading(Date.yesterday)
    assert_equal I18n.t("entries.days.tomorrow"), day_heading(Date.tomorrow)
    assert_equal I18n.l(Date.new(2025, 12, 30), format: :day_with_year), day_heading(Date.new(2025, 12, 30))

    travel_to Date.new(2026, 6, 15)

    assert_equal I18n.l(Date.new(2026, 6, 1), format: :day), day_heading(Date.new(2026, 6, 1))
  end

  test "links in notes can be followed" do
    url = "https://example.com/moon?phase=full"
    link = Nokogiri::HTML5.fragment(notes_with_links("Watched (#{url}).")).at_css("p a")

    assert_equal url, link["href"]
    assert_equal url, link.text
  end

  test "notes can't sneak in HTML" do
    html = Nokogiri::HTML5.fragment(notes_with_links("<script>alert(1)</script>"))

    assert_empty html.css("script")
  end
end
