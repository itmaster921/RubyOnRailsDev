class UserMailer < ApplicationMailer
  def membership_card_reminder(user, venue)
    @user = user
    @venue = venue
    mail(to: @user.email, subject: t('mailer.user..credit_card_reminder'))
  end
end
