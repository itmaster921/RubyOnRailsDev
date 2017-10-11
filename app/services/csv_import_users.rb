class CSVImportUsers < CSVImportBase
  def initialize(file, venue, quote_char = nil)
    @venue = venue

    super(file, quote_char)
  end


  def valid_input?
    @errors << t('no_venue') unless @venue.is_a?(Venue)

    super
  end

  private

  def self.columns_legend
    {
      first_name:     { placeholder: "John", required: true },
      last_name:      { placeholder: "Doe", required: true },
      email:          { placeholder: "example@mail.com", required: true },
      phone_number:   { placeholder: "0000000", required: false },
      street_address: { placeholder: "1st road", required: false },
      zipcode:        { placeholder: "50000", required: false },
      city:           { placeholder: "Chicago", required: false }
    }
  end

  def process_row(params)
    user = User.new(sanitize_params(params))
    existing_user = User.where(email: user.email).take

    if existing_user
      connect_to_venue(existing_user)
      # skip already created
      self.skipped_count += 1
    elsif user.valid?
      user.skip_confirmation_notification!
      user.save
      connect_to_venue(user)
      send_confirmation(user)
      self.created_count += 1
    else
      self.invalid_rows << user
    end
  rescue Exception => e
    user = User.new
    user.errors.add('_', t('failed_to_process_data', data: params.to_s))
    self.invalid_rows << user
    p e.message
  end

  def connect_to_venue(user)
    @venue.users << user unless @venue.users.include?(user)
  end

  def send_confirmation(user)
    ConfirmationMailer.confirmation_instructions(
      user,
      user.confirmation_token,
      {},
      @venue
    ).deliver_later
  end

  def sanitize_params(params)
    params[:email] = params[:email].to_s.downcase

    params
  end
end
