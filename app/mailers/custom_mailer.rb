class CustomMailer < ApplicationMailer

  # Custom mail created and sent by admin
  def custom_mail(mail_params, venue_id)
    venue = Venue.find(venue_id)
    @subject = mail_params['subject']
    @body = mail_params['body']
    @image_url = ""
    if mail_params['header_image_path']
      attachments.inline['header_image.jpg'] = File.read(mail_params['header_image_path'])
      @image_url = attachments.inline['header_image.jpg'].url
    else
      @image_url = venue.primary_photo.image.url
    end

    mail(
      to: mail_params['to'],
      subject: @subject,
      from: mail_params['from']
    )
  end
end
