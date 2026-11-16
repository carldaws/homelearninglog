module EntriesHelper
  LINK = %r{(https?://[^\s<]+[^\s<.,;:!?)\]'"])}

  def day_heading(date)
    if date == Date.current
      t("entries.days.today")
    elsif date == Date.yesterday
      t("entries.days.yesterday")
    else
      l(date, format: date.year == Date.current.year ? :day : :day_with_year)
    end
  end

  def duration(minutes)
    hours, remainder = minutes.divmod(60)
    [ (t("entries.duration.hours", count: hours) if hours.positive?), (t("entries.duration.minutes", count: remainder) if remainder.positive?) ].compact.join(" ")
  end

  def duration_options(selected)
    Entry::SUGGESTED_MINUTES.including(selected).compact.uniq.sort.map { [ duration(it), it ] }
  end

  def notes_with_links(notes)
    simple_format(safe_join(notes.split(LINK).map { it.match?(LINK) ? link_to(it, it, class: "link break-all", rel: "noopener", target: "_blank") : it }), {}, sanitize: false)
  end
end
