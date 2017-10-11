# Send email confirmations for bookings
class BookingMailer < ApplicationMailer
  def booking_email(user, reservation)
    @user = user
    @reservation = reservation
    @venue = @reservation.court.venue
    subject = t('mailer.booking.subject',
                venue_name: @venue.venue_name,
                date: TimeSanitizer.output(@reservation.start_time)
                                   .strftime('%d/%m/%Y %H:%M'))

    mail(to: @user.email, subject: subject)
  end
end
