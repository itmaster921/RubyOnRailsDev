class CancellationMailer < ApplicationMailer
  def cancellation_email(user, reservation)
    @user = user
    @reservation = reservation
    @venue = @reservation.court.venue
    mail(to: @user.email, subject: "Varauksesi #{@reservation.start_time.strftime("%D")} #{@reservation.court.venue.venue_name} on peruttu.")
  end
end
