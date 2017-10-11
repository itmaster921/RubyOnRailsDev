class PagesController < ApplicationController
  def home
    @venues = Venue.all.where(listed: true)
    @selected_sport = 'tennis'
    @sport_options = ['padel']
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
end
