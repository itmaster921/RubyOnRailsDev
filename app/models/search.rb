class Search
  attr_reader :sport_name, :date_time, :duration, :margin, :limit, :page, :venue, :user, :date, :week_day

  def initialize(params)
    @date_time  = params[:date_time].in_time_zone || Time.current
    @duration   = params[:duration]    || 60
    @limit      = params[:limit]       || 5
    @page       = params[:page]        || 1
    @sport_name = Court.sport_names[params[:sport_name].to_s]
    @venue      = params[:venue] if params[:venue] && params[:venue].is_a?(Venue)
    @user       = User.includes(:discounts).find_by_id(params[:user_id]) if params[:user_id]
    @date       = date_time.to_date
    @week_day   = date_time.strftime('%A').to_s.downcase.to_sym

    @taken_courts = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    @court_available_times = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    @min_prices = {}
    @max_prices = {}
    @all_available_times = {}
  end

  def result
    @result = {}
    find_venues
    find_courts
    find_existing_reservations

    @courts_by_venues.each do |venue_id, courts|
      @result[courts.first.venue] = find_possible_reservations(courts.first.venue, courts)
    end

    @result
  end

  def venue_result
    result[venue]
  end

  def venues_result
    result.map do |venue, data|
      {
        venue: venue,
        data: {
          court_available_times: @court_available_times[venue.id],
          min_price: @min_prices[venue.id],
          max_price: @max_prices[venue.id],
          all_available_times: all_available_times(venue.id),
          marginalized_available_times: closest_available_times(venue.id),
          time_slots: @result[venue]
        }
      }
    end
  end

  def all_available_times(venue_id)
    @all_available_times[venue_id] = @court_available_times[venue_id].values.flatten.sort.uniq
  end

  def closest_available_times(venue_id)
    availables = @all_available_times[venue_id].dup
    current_minute = date_time.minute_of_a_day

    while availables.count > @limit
      if current_minute - availables.first > availables.last - current_minute
        availables.shift
      else
        availables.pop
      end
    end

    availables
  end

  private

  def find_venues
    venue_scope =  Venue.includes(:courts).listed
                        .where(courts: { sport_name: sport_name })
                        .where('booking_ahead_limit > ?', (date - Date.current).to_i)

    # it shouldn't skip other validations
    venue_scope = venue_scope.where(id: [venue.id]) if venue.present?

    # venues for current page (TODO: pagination, location)
    @venues = venue_scope.limit(27).load
  end

  def find_courts
    @courts =  Court.active.common
                    .where(sport_name: sport_name, venue_id: @venues.map(&:id).uniq)
                    .where('duration_policy <= ?', duration)
                    .includes(:prices, :day_offs, venue: [:day_offs, :photos]).load
    @courts_ids = @courts.map(&:id)
    @courts_by_venues = @courts.group_by(&:venue_id)
  end

  def find_existing_reservations
    @existing_reservations = Reservation.on_date(date).where(court_id: @courts_ids).group_by(&:court_id)
  end

  def find_possible_reservations(venue, courts)
    reservations = Hash.new { |h, k| h[k] = {} }

    venue.time_frames(duration, date).each do |time_frame|
      availables = available_coutrs(time_frame, courts)
      # taken courts not suported in view
      reservations[time_frame.to_key] = availables if availables['available_courts'].count > 0 # || availables['taken_courts'].count > 0
    end

    reservations
  end

  def available_coutrs(time_frame, courts)
    available_coutrs = []
    courts.each do |court|
      if check_availability(time_frame, court)
        res = available_court_hash(time_frame, court)
        available_coutrs << res

        @court_available_times[court.venue.id][court.id] << time_frame.start_minute_of_day
        vid = court.venue.id
        @min_prices[vid] = res['price'] if !@min_prices[vid] || @min_prices[vid] > res['price']
        @max_prices[vid] = res['price'] if !@max_prices[vid] || @max_prices[vid] < res['price']
      end
    end
    available_coutrs.sort! { |a, b| a['price'] <=> b['price'] }
    {
      'duration'          => duration,
      'available_courts'  => available_coutrs,
      'taken_courts'      => @taken_courts[courts.first.venue.id][time_frame],
      'available'         => available_coutrs.size > 0,
      'lowest_price'      => available_coutrs.first.try(:[], 'price')
    }
  end

  def available_court_hash(time_frame, court)
    {
      'id' => court.id,
      'price' => court.price_at(time_frame.starts, time_frame.ends, discount(court.venue.id)),
      'name' => court.court_name,
      'payment_skippable' => court.payment_skippable || false
    }
  end

  def check_availability(time_frame, court)
    # start time policy
    court.can_start_at?(time_frame.starts) &&
      # not on offday
      court.working?(time_frame.starts, time_frame.ends) &&
      # has price
      court.has_price?(time_frame.starts, time_frame.ends) &&
      # not reserved
      free_court_time_frame?(time_frame, court)
  end

  def free_court_time_frame?(time_frame, court)
    return true unless @existing_reservations[court.id]

    if @existing_reservations[court.id].none? { |r| r.overlapping?(time_frame.starts, time_frame.ends) }
      true
    else
      @taken_courts[court.venue.id][time_frame] << { 'id' => court.id }
      false
    end
  end

  def discount(venue_id)
    user ? user.discount_for(venue_id) : nil
  end
end
