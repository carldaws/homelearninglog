module EntriesHelper
  TRAILING_PUNCTUATION = %q{.,;:!?)]'"}
  LINK = %r{https?://[^\s<]*[^\s<#{Regexp.escape(TRAILING_PUNCTUATION)}]}

  def day_heading(date)
    if date == Date.current
      t("entries.days.today")
    elsif date == Date.yesterday
      t("entries.days.yesterday")
    elsif date == Date.tomorrow
      t("entries.days.tomorrow")
    else
      l(date, format: date.year == Date.current.year ? :day : :day_with_year)
    end
  end

  def week_heading(starts_on)
    if starts_on == Date.current.beginning_of_week
      t("entries.weeks.this_week")
    elsif starts_on == Date.current.prev_week
      t("entries.weeks.last_week")
    else
      t("entries.weeks.week_of", date: l(starts_on, format: starts_on.year == Date.current.year ? :short : :short_with_year))
    end
  end

  def duration(minutes)
    hours, remainder = minutes.divmod(60)

    parts = []
    parts << t("entries.duration.hours", count: hours) if hours.positive?
    parts << t("entries.duration.minutes", count: remainder) if remainder.positive?
    parts.join(" ")
  end

  def duration_options(selected)
    Entry::SUGGESTED_MINUTES.including(selected).compact.uniq.sort.map { [ duration(it), it ] }
  end

  def text_with_links(text)
    parts = text.split(/(#{LINK})/).map do |part|
      part.match?(LINK) ? link_to(part, part, class: "link break-words", rel: "noopener", target: "_blank") : part
    end

    simple_format safe_join(parts), {}, sanitize_options: { attributes: %w[ href class rel target ] }
  end
end
