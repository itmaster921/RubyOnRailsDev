# Loops through the recipient emails and sends indivisual mails
class CustomMailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(mail_params, venue_id)
    mhash = mail_params.slice('from', 'subject', 'body', 'header_image_path')
    mail_params['to'].each do |recipient_email|
      mhash['to'] = recipient_email
      CustomMailer.custom_mail(mhash, venue_id).deliver_now
    end

    logger.info "  Sent #{mail_params['to'].count} mails."
  end
end
