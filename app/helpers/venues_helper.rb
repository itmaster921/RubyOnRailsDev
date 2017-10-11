module VenuesHelper
  def minute_of_a_day_to_time(val)
    h = val / 60
    m = val % 60
    h = "0#{h}" if h < 10
    m = "0#{m}" if m < 10
    "#{h}:#{m}"
  end

  def options_for_time_select
    hours = '06'..'22'
    minutes = ['00', '30']

    hours.map do |h|
      minutes.map do |m|
        h + ':' + m
      end
    end.flatten
  end

  # select dropdown for searchTime
  # time is optional arg in format "HH:MM"
  def search_time_select_box(time = nil)
    select_tag 'searchTime',
      options_for_select(
        options_for_time_select,
        time || TimeSanitizer.time_ceil_at(DateTime.now.in_time_zone, 30).strftime('%H:%M')
      ),
      class: 'select2_time form-control'
  end
end
