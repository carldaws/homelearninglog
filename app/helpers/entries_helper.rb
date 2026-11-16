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

  def notes_with_links(notes)
    parts = notes.split(/(#{LINK})/).map do |part|
      part.match?(LINK) ? link_to(part, part, class: "link break-words", rel: "noopener", target: "_blank") : part
    end

    simple_format safe_join(parts), {}, sanitize_options: { attributes: %w[ href class rel target ] }
  end
end
