# Sanitize JSON booking params into reservations
class ReservationSanitizer
  def initialize(user, params)
    @user = user
    @duration = params[:duration].to_i
    @date = parse_date(params[:date])
    @pay = params[:pay].present?
    @token = params[:card].to_s
    @bookings = sanitize_bookings(params[:bookings])
  end

  # Returns a list of created reservations or nil
  def create_reservations
    reservations = build_reservations
    return nil unless reservations.any? && reservations.all?(&:valid?)
    reservations = commit_reservations(reservations)
    return nil unless reservations.all?(&:persisted?)
    charge(reservations) if @pay

    reservations
  end

  # Returns a list of built reservations
  def build_reservations
    @bookings.map do |booking|
      Reservation.new(booking).take_matching_resell
    end
  end

  private

  def sanitize_bookings(bookings)
    bookings = JSON.parse(bookings) rescue []

    bookings.map do |booking|
      sanitize_booking(booking)
    end
  end

  def sanitize_booking(booking)
    start_time = parse_start_time(booking)
    end_time = calculate_end_time(start_time)
    court = find_court(booking)
    price = calculate_price(court, start_time, end_time)
    {
      user: @user,
      start_time: start_time,
      end_time: end_time,
      court: court,
      price: price,
      booking_type: :online,
      payment_type: :unpaid
    }
  end

  def commit_reservations(reservations)
    Reservation.transaction do
      reservations.each do |reservation|
        reservation.skip_booking_mail!
        reservation.save!
        reservation.court.venue.add_customer(@user)
      end
      # track and mail only if all reservations succesfully saved
      reservations.each do |reservation|
        reservation.booking_mail
        reservation.track_booking
      end
    end
  rescue
    reservations
  end

  def charge(reservations)
    reservations.map do |r|
      r.charge(@token)
    end
  end

  def parse_date(date)
    TimeSanitizer.input("#{date} 00:00").in_time_zone.to_date rescue nil
  end

  def parse_start_time(booking)
    TimeSanitizer.input(booking['start_time'].to_s) rescue nil
  end

  def calculate_end_time(start_time)
    return nil if start_time.blank?

    start_time + @duration.minutes
  end

  def calculate_price(court, start_time, end_time)
    return nil if court.blank? || start_time.blank? || end_time.blank?

    court.price_at(start_time, end_time, discount(court.venue.id))
  end

  def discount(venue_id)
    @user.blank? ? nil : @user.discount_for(venue_id)
  end

  def find_court(booking)
    Court.find_by_id(booking['id'])
  end
end
