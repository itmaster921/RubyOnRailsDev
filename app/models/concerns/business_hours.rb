# Handles venue opening and closing hours
module BusinessHours
  extend ActiveSupport::Concern

  DAYS = [:sun, :mon, :tue, :wed, :thu, :fri, :sat].freeze

  def closing_hours
    closing_times = []
    7.times.each do |index|
      closing_times += daily_business_hours(index)
    end
    closing_times
  end

  def business_hours_ready?
    business_hours.each do |_, value|
      return false unless value[:opening] && value[:closing]
    end
    business_hours.keys.count == 7
  end

  def parse_business_hours(hours)
    self.business_hours = {
      mon: business_hours_pair(hours, :mon),
      tue: business_hours_pair(hours, :tue),
      wed: business_hours_pair(hours, :wed),
      thu: business_hours_pair(hours, :thu),
      fri: business_hours_pair(hours, :fri),
      sat: business_hours_pair(hours, :sat),
      sun: business_hours_pair(hours, :sun)
    }
  end

  def in_business?(start_time, end_time)
    start_time = TimeSanitizer.output(start_time)
    end_time = TimeSanitizer.output(end_time)

    opening_local(start_time) <= start_time &&
      closing_local(start_time) >= end_time &&
      working?(start_time, end_time)
  end

  def working?(start_time, end_time)
    day_offs.each do |dayoff|
      return false if dayoff.covers?(start_time, end_time)
    end
    true
  end

  # Returns opening time as hh:mm in local time
  def opening(day)
    Time.now.utc.midnight
        .advance(seconds: opening_second(day)).strftime('%H:%M')
  end

  # Returns closing time as hh:mm in local time
  def closing(day)
    Time.now.utc.midnight
        .advance(seconds: closing_second(day)).strftime('%H:%M')
  end

  def opening_local(date)
    dow = date.strftime('%a').downcase
    TimeSanitizer.add_seconds(date, opening_second(dow))
  end

  def closing_local(date)
    dow = date.strftime('%a').downcase
    TimeSanitizer.add_seconds(date, closing_second(dow))
  end

  def opening_second(dow)
    business_hours.try(:[], dow).try(:[], :opening) || 0
  end

  def closing_second(dow)
    business_hours.try(:[], dow).try(:[], :closing) || 86399
  end

  private

  # @OUTPUT method
  def daily_business_hours(day)
    [{
      start: Time.zone.today.at_beginning_of_day.strftime('%H:%M'),
      end: opening(DAYS[day]),
      dow: [day]
    }, {
      start: closing(DAYS[day]),
      end: Time.zone.today.at_end_of_day.strftime('%H:%M'),
      dow: [day]
    }]
  end

  def business_hours_pair(hours, dow)
    { opening: tod(hours[:opening][dow]), closing: tod(hours[:closing][dow]) }
  end

  # business hours are excempt from time sanitization including comparison in
  # in_business? due to problems with wrap arounds
  # 1 AM local opening time becomes 22:00 in seconds_since_midnight utc
  # maybe a better way to handle wrap around
  def tod(time)
    Time.zone.parse(time).seconds_since_midnight
  end
end
