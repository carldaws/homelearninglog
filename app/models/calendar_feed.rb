class CalendarFeed
  WEEKS_BEHIND = 8
  WEEKS_AHEAD = 26
  LINE_LENGTH = 75

  attr_reader :family

  def initialize(family)
    @family = family
  end

  def to_ics
    lines = [ "BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//#{escape(I18n.t("app.name"))}//EN", "CALSCALE:GREGORIAN",
      "X-WR-CALNAME:#{escape(family.name)}", *occurrences.flat_map { event_lines(it) }, "END:VCALENDAR" ]

    lines.map { fold(it) }.join("\r\n") + "\r\n"
  end

  private
    def occurrences
      family.occurrences_between((Date.current - WEEKS_BEHIND.weeks)..(Date.current + WEEKS_AHEAD.weeks)).reject(&:cancelled?)
    end

    def event_lines(occurrence)
      [ "BEGIN:VEVENT", "UID:#{occurrence.event.id}-#{occurrence.date.iso8601}@learninglog",
        "DTSTAMP:#{utc(occurrence.event.updated_at)}", *time_lines(occurrence),
        "SUMMARY:#{escape(occurrence.title)}", "DESCRIPTION:#{escape(description(occurrence))}", "END:VEVENT" ]
    end

    def time_lines(occurrence)
      if occurrence.starts_at.present?
        [ "DTSTART:#{utc(occurrence.starts_at)}", ("DTEND:#{utc(occurrence.ends_at)}" if occurrence.ends_at.present?) ].compact
      else
        [ "DTSTART;VALUE=DATE:#{occurrence.date.strftime("%Y%m%d")}", "DTEND;VALUE=DATE:#{occurrence.date.tomorrow.strftime("%Y%m%d")}" ]
      end
    end

    def description(occurrence)
      grown_up = occurrence.grown_up.name if occurrence.grown_up.present?
      [ occurrence.children.map(&:name).sort.to_sentence, grown_up, occurrence.event.notes ].compact_blank.join("\n")
    end

    def utc(time)
      time.utc.strftime("%Y%m%dT%H%M%SZ")
    end

    def escape(text)
      text.gsub(/[\\;,]/) { "\\#{it}" }.gsub(/\r?\n/, "\\n")
    end

    def fold(line)
      line.each_char.each_with_object([ +"" ]) do |char, chunks|
        limit = chunks.one? ? LINE_LENGTH : LINE_LENGTH - 1
        chunks << +"" if (chunks.last + char).bytesize > limit
        chunks.last << char
      end.join("\r\n ")
    end
end
