class API::VenuesController < ApplicationController
  def index
    @venues = Venue.listed.includes(:courts, :photos)
    @venues = @venues.sport(params[:sport]) if params[:sport].present?
  end

  def users
    @users = Venue.find(params[:venue_id]).users
    .select(:id, :first_name, :last_name, :email).distinct.map{ |p| {value: p.id, label:p.first_name.capitalize+" "+p.last_name.capitalize + " " + p.email}}
  end

  def show
    @venue = Venue.find(params[:id])
  end

  def all_sport_names
    @sport_names = Venue.all_sport_names
  end

  def utilization_rate
    v = Venue.find(params[:venue_id])
    @times = []
    @rates = []
    time = TimeSanitizer.output(v.opening(Date.today.strftime("%a").underscore))
    while (time < TimeSanitizer.output(v.closing(Date.today.strftime("%a").underscore)))
      bookings = 0.0
      v.courts.each do |court|
        if court.reservations.where("? >= start_time AND ? < end_time", time, time)
          .length > 0
          bookings += 1
        end
      end
      @times << time.strftime("%H:%M")
      @rates << ((bookings/v.courts.count) * 100).round
      time += 1.hours
    end
  end

  def sort_by_sport
    @sport = params[:sport]
    case @sport
    when 'tennis'
      @venues = Venue.listed
    when 'padel'
      @venues = Venue.listed.padel
    else
      @sport = 'tennis'
      @venues = Venue.listed.tennis
    end
  end

  def search
    @time = TimeSanitizer.input("#{params[:date]} #{params[:time]}")
                        .beginning_of_hour
    if params['date'].present? &&
       params['time'].present? &&
       params['duration'].present?

      @cards = current_user.cards if user_signed_in? && current_user.has_stripe?

      @duration = params[:duration].to_i
      search = Search.new(
        date_time: @time,
        duration: @duration,
        user_id: params['userId'],
        sport_name: params[:sport_name]
      )

      @venues_data = search.venues_result

      @available_times = @venues_data.map {|x| x[:data][:all_available_times].any?}.reduce(false) {|a,b| a ||= b}
    else
      @available = nil
      @available_times = false
    end
  end

  def available_courts

    @venue = Venue.find(params[:venue_id])
    @time = TimeSanitizer.input("#{params[:date]}  #{params[:time]}")
                         .beginning_of_hour
    @duration = params[:duration].to_i
    search = Search.new(
      date_time: @time,
      duration: @duration,
      venue: @venue,
      user_id: params['userId'],
      sport_name: params[:sport_name]
    )

    @available = search.venue_result
  end

end
