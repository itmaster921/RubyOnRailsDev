class TimeFrame
  attr_reader :starts, :ends

  def initialize(starts, ends)
    @starts = TimeSanitizer.output(starts)
    @ends = TimeSanitizer.output(ends)
  end

  def start_minute_of_day
    @start_minute_of_day ||= @starts.minute_of_a_day
  end

  def end_minute_of_day
    @start_minute_of_day ||= @starts.minute_of_a_day
  end

  def to_key
    @key ||= @starts.to_s
  end
end
