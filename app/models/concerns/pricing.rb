# Handles checking court pricing rules
module Pricing
  extend ActiveSupport::Concern

  DAYS = {
    mon: :monday?,
    tue: :tuesday?,
    wed: :wednesday?,
    thu: :thursday?,
    fri: :friday?,
    sat: :saturday?,
    sun: :sunday?
  }.freeze

  def pricing_ready?
    ppday = prices_per_day
    errors = {}
    ppday.keys.each do |day|
      day_errors = day_errors(ppday[day], day).compact
      errors[day] = day_errors unless day_errors.empty?
    end
    errors
  end

  private

  def day_errors(day_prices, day)
    opening_time, closing_time = business_hours_for_day(day)
    start_times = day_prices.map(&:start_minute_of_a_day) +
                  [closing_time]
    end_times = [opening_time] + day_prices.map(&:end_minute_of_a_day)

    Array.new(start_times.length) do |idx|
      compare_time(end_times[idx],
                   start_times[idx])
    end
  end

  def compare_time(start_time, end_time)
    return time_error(start_time, end_time) if end_time - start_time > 0
  end

  def time_error(start_time, end_time)
    start_time = TimeSanitizer.add_minutes(Time.current, start_time).strftime('%H:%M')
    end_time = TimeSanitizer.add_minutes(Time.current, end_time).strftime('%H:%M')
    "Time from #{start_time} to #{end_time} has no pricing"
  end

  def business_hours_for_day(day)
    [venue.opening_second(day) / 60,
     venue.closing_second(day) / 60]
  end

  def prices_per_day
    ppday = {}
    DAYS.keys.each do |day|
      ppday[day] = prices.select(&DAYS[day]).sort_by(&:start_minute_of_a_day)
    end
    ppday
  end
end
