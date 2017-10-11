module VenueTimeFrames
  extend ActiveSupport::Concern

  def time_frames(duration, date = Date.current)
    @time_frames ||= Hash.new { |h, k| h[k] = {} }
    duration = duration.to_i
    date = TimeSanitizer.output(date).to_date

    return @time_frames[duration][date] if @time_frames[duration][date]

    @time_frames[duration][date] = calculate_time_frames(opening_local(date), closing_local(date), duration.minutes)
  end

  def calculate_time_frames(start_time, end_time, duration)
    time_frames = []
    current = TimeFrame.new(start_time, start_time + duration)

    while current.starts < end_time
      time_frames << current if current.starts > Time.current
      current = TimeFrame.new(current.starts + 30.minutes, current.ends + 30.minutes)
    end

    time_frames
  end
end
