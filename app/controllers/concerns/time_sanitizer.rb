# Handles sanitization of input and output time fields
# Taking time input from user and displaying time to user
# must be done explicitly through this module
module TimeSanitizer
  extend ActiveSupport::Concern

  # All input time must be parsed in the user timezone
  # then changed IMMEDIATLY to UTC
  def self.input(date_time)
    Time.zone.parse(date_time)
        .utc
  end

  def self.output_input(date_time)
    output(input(date_time))
  end

  # create time adding seconds to beginning of day
  # ignore dst!, + 86400 seconds should be beginning of the next day without adding or losing hour
  def self.add_seconds(date, seconds)
    beginning = self.output(date).beginning_of_day

    time = beginning + seconds.to_i
    # utc delta == +/- seconds shift on dst transition
    utc_delta = beginning.utc_offset - time.utc_offset

    time + utc_delta
  end

  def self.add_minutes(date, minutes)
    self.add_seconds(date, minutes.to_i * 60)
  end

  # All output time must be in utc then converted
  # to local time
  # input MUST be a Time Object
  def self.output(time)
    time.in_time_zone
  end

  # safe formatted output for views
  # accepts DATE_FORMATS symbols or srtftime format
  def self.strftime(time, format)
    if format.is_a?(Symbol)
      output(time).to_s(format)
    else
      output(time).strftime(format)
    end
  rescue
    ''
  end

  # tries localized strftime, fallbacks to usual
  def self.localize(time, format)
    I18n.localize(time, format: format)
  rescue
    strftime(time, format)
  end

  # returns next given time step
  # ex: 30 mins => 10:30
  def self.time_ceil_at(datetime, min)
    step = min * 60
    result = Time.at( (datetime.to_f / step).ceil * step )
    output(result)
  end
end
