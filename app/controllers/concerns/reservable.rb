# handles venue reservation from user side
module Reservable
  extend ActiveSupport::Concern

  def make_reservation
    unless current_user
      msg = { status: 'error', message: 'Log in to book!', html: '<b>...</b>' }
      render json: msg && return
    end
    paid = true
    reservations = make_reservations(params[:bookings], paid)
    reservations = save_reservations(reservations, @venue, paid)

    reservations_response(errors(reservations))
  end

  def make_unpaid_reservation
    unless current_user
      msg = { status: 'error', message: 'Log in to book!', html: '<b>...</b>' }
      render json: msg && return
    end

    reservations = make_reservations(params[:bookings])
    reservations = save_reservations(reservations, @venue)

    reservations_response(errors(reservations))
  end

  private

  def reservations_response(errors)
    if errors.empty?
      render nothing: true, status: :ok
    else
      render json: errors.uniq, status: 422
    end
  end

  def save_reservations(reservations, venue, paid=false)
    Reservation.transaction do
      reservations.each do |reservation|
        reservation.skip_booking_mail!
        reservation.save!
        reservation.court.venue.add_customer(reservation.user)
      end
      # pay, track and mail only if all reservations succesfully saved
      reservations.each do |reservation|
        handle_payment(reservation) if paid
        reservation.booking_mail
        reservation.track_booking
      end
    end
  rescue
    reservations
  end

  def make_reservations(bookings, paid=false)
    bookings.values.map do |p|
      Reservation.new(sanitize_booking_params(p, paid)).take_matching_resell
    end
  end

  def sanitize_booking_params(p, paid=false)
    start_time = TimeSanitizer.input(p[:datetime])
    end_time = start_time + p[:duration].to_i.minutes
    current_court = Court.find(p[:id])
    if paid
      { start_time: start_time, end_time: end_time,
        court: current_court, price: calculate_price(current_court,
                                                     start_time,
                                                     end_time),
        payment_type: :paid, booking_type: :online,
        user: current_user, game_pass_id: p[:game_pass_id] }
    else
      { start_time: start_time, end_time: end_time,
        court: current_court, price: calculate_price(current_court,
                                                     start_time,
                                                     end_time),
        payment_type: :unpaid, booking_type: :online,
        user: current_user }
    end

  end

  def calculate_price(court, start_time, end_time)
    discount = current_user.discounts
                           .find_by(venue_id: court.venue
                                                   .id)
    court.price_at(start_time, end_time, discount)
  end

  def handle_payment(reservation)
    reservation.use_game_pass_or_pay(params[:card])
  end

  def errors(reservations)
    reservations.map { |r| r.errors.any? ? r.errors.full_messages : nil }.flatten.compact
  end
end
