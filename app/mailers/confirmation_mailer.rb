class ConfirmationMailer < Devise::Mailer
  helper :application #
  include Devise::Controllers::UrlHelpers #
  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, opts = {}, venue = nil)
    if venue.present?
      @venue = venue
      opts[:subject] = "#{@venue.venue_name} on luonut sinulle tilin mywebsiteiin"
    end
    super(record, token, opts)
  end
end
