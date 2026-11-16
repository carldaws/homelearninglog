module CalendarsHelper
  def times(occurrence)
    [ occurrence.start_time, occurrence.end_time ].compact.map { l(it, format: :clock) }.join("–")
  end
end
