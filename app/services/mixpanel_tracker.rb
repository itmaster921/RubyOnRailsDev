# Handles statistics tracking using mixpanel
class MixpanelTracker
  def self.tracker
    @tracker ||= Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
  end

  def self.credit_card(user)
    tracker.track(user.id,
                  'Credit Card added by User',
                  time_form_signup: (Time.now.utc - Time.parse(user.created_at
                                                                   .to_s)
                                                        .utc).round)
  rescue
  end

  def self.booking(venue, reservation, user, source = "User")
    tracker.track(
      user.id,
      "Paid Booking Done By #{source}",
      venue_id: venue.id, venue_name: venue.venue_name,
      reservation_id: reservation.id,
      first_reservation_timestamp: time_diff(user.created_at,
                                             reservation.created_at),
      price: reservation.price, court_id: reservation.court_id
    )
  rescue
  end

  def self.unpaid_booking(venue, reservation, user, source = "User")
    tracker.track(
      user.id,
      "Unpaid Booking Done By #{source}",
      venue_id: venue.id, venue_name: venue.venue_name,
      reservation_id: reservation.id,
      first_reservation_timestamp: time_diff(user.created_at,
                                             reservation.created_at),
      price: reservation.price, court_id: reservation.court_id
    )
  rescue
  end

  def self.cancellation(reservation, user, title)
    user ||= reservation.user
    venue = reservation.court.venue
    tracker.track(
      user.id,
      title,
      owner_id: reservation.user.id,
      venue_id: venue.id,
      venue_name: venue.venue_name,
      price: reservation.price,
      court_id: reservation.court.id
    )
  rescue
  end

  def self.user_cancellation(reservation, user)
    cancellation(reservation, user, "Bookings Cancelled By User")
  end

  def self.admin_cancellation(reservation, user)
    cancellation(reservation, user, "Bookings Cancelled By Admin")
  end

  def self.user_resell(reservation, user)
    cancellation(reservation, user, "Booking Resell By User")
  end

  def self.admin_resell(reservation, user)
    cancellation(reservation, user, "Booking Resell By Admin")
  end

  private_class_method

  def self.time_diff(start_time, end_time)
    start_time = Time.parse(start_time.to_s).utc
    end_time = Time.parse(end_time.to_s).utc
    (end_time - start_time).round
  end
end
