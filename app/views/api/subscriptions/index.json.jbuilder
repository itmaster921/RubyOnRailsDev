json.array! @subscriptions do |reservation|
  json.venue do
    json.link venue_path(reservation.court.venue)
    json.imageUrl reservation.court.venue.try(:primary_photo).try(:image).try(:url)
    json.street reservation.court.venue.street
    json.zip reservation.court.venue.zip
    json.city reservation.court.venue.city
    json.phone_number reservation.court.venue.phone_number
    json.website reservation.court.venue.website
    json.name reservation.court.venue.venue_name
  end
  json.id reservation.id
  json.booking_type reservation.booking_type
  json.court reservation.court
  json.month TimeSanitizer.output(reservation.start_time).try(:strftime, '%B')
  json.day TimeSanitizer.output(reservation.start_time).try(:strftime, '%d')
  json.year TimeSanitizer.output(reservation.start_time).try(:strftime, '%Y')
  json.start_time TimeSanitizer.output(reservation.start_time).try(:strftime, '%H:%M')
  json.end_time TimeSanitizer.output(reservation.end_time).try(:strftime, '%H:%M')
  json.price number_to_currency(reservation.price)
  json.calendarLink venue_reservation_path(reservation.court.venue.id, reservation.id, format: :ics)
  if reservation.unpaid?
    json.payment_type t('users.show.reservation_unpaid')
  else
    json.payment_type t('users.show.reservation_paid')
  end
  if reservation.cancelable?
    json.cancelLink api_reservation_path(reservation)
  else
    json.cancelMessage t('users.show.cancellation_policy', time: reservation.court.venue.cancellation_time,
                                                           venue: reservation.court.venue.venue_name)
  end
end
