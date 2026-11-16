Log::Week = Data.define(:starts_on, :entries) do
  def days
    entries.group_by(&:happened_on)
  end

  def minutes
    entries.filter_map(&:minutes).sum
  end
end
