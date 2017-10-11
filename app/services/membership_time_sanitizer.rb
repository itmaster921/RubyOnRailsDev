# prepare tparams

class MembershipTimeSanitizer
  def initialize(params)
    @params = params

    @weekday = @params[:weekday].to_s.capitalize

    if !Date::DAYNAMES.include?(@weekday)
      @weekday = membership_start_time.in_time_zone.strftime('%A')
    end
  end

  # time params in UTC
  def time_params
    {
      membership_start_time: membership_start_time,
      membership_end_time: membership_end_time,
      start_time: reservations_start_time,
      end_time: reservations_end_time
    }
  end

  def membership_start_time
    @membership_start_time ||= TimeSanitizer.input(
      "#{@params[:start_date]} #{@params[:start_time]}"
    )
  end

  def membership_end_time
    @membership_end_time ||= TimeSanitizer.input(
      "#{@params[:end_date]} #{@params[:end_time]}"
    )
  end

  def reservations_start_time
    return @reservations_start_time if @reservations_start_time

    start = membership_start_time
    while start.strftime('%A') != @weekday
      start = start.advance(days: 1)
    end

    @reservations_start_time = start
  end

  def reservations_end_time
    @reservations_end_time ||= TimeSanitizer.input(
      "#{reservations_start_time.to_s(:date)} #{@params[:end_time]}"
    )
  end

  def last_reservation_start_time
    start = TimeSanitizer.input(@params[:start_time] + ' ' + @params[:end_date])

    while start.strftime('%A') != @weekday
      start = start.advance(days: -1)
    end

    start
  end
end
