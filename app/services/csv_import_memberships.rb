class CSVImportMemberships < CSVImportBase
  def initialize(file, venue, ignore_conflicts, quote_char = nil)
    @venue = venue
    @ignore_conflicts = ignore_conflicts ? true : false

    super(file, quote_char)
  end

  def valid_input?
    @errors << t('no_venue') unless @venue.is_a?(Venue)

    super
  end

  private

  def self.columns_legend
    {
      email:         { placeholder: "example@mail.com", required: true,
                        comment: t('column_comments.email') },
      start_date:    { placeholder: "11/01/2017", required: true,
                        comment: 'DD/MM/YYYY' },
      end_date:      { placeholder: "11/02/2017", required: true,
                        comment: 'DD/MM/YYYY' },
      start_time:    { placeholder: "10:00", required: true,
                        comment: 'HH:MM ' + t('column_comments.local_timezone') },
      end_time:      { placeholder: "11:00", required: true,
                        comment: 'HH:MM ' + t('column_comments.local_timezone') },
      weekday:       { placeholder: "Tuesday", required: true },
      price:         { placeholder: "10.0", required: true },
      court_index:   { placeholder: "1", required: true,
                        comment: t('column_comments.court_index') },
      court_sport:   { placeholder: "tennis", required: true,
                        comment: t('column_comments.court_sport',
                                    defaults: Court.sport_names.keys.join(', '))
                      },
      court_outdoor: { placeholder: "outdoor", required: false,
                        comment: t('column_comments.court_outdoor') }
    }
  end

  def process_row(params)
    params = sanitize_params(params)
    return if no_time_data?(params)

    membership = Membership.new(membership_params(params))

    if membership.save
      self.created_count += 1
    elsif membership.already_imported?
      self.skipped_count += 1
    else
      self.invalid_rows << { name: membership_name(params),
                             membership: membership }
    end
  rescue Exception => e
    membership = Membership.new
    membership.errors.add('_', t('failed_to_process_data', data: params.to_s))
    self.invalid_rows << { name: t('corrupted_data'),
                             membership: membership }
    p e.message
  end

  def no_time_data?(params)
    params[:start_date].blank? || params[:end_date].blank? ||
      params[:start_time].blank? || params[:end_time].blank?
  end

  def membership_params(params)
    sanitizer = MembershipTimeSanitizer.new(params)

    {
      importing: true,
      import_data: params.dup,
      venue: @venue,
      price: params[:price],
      start_time: sanitizer.membership_start_time,
      end_time: sanitizer.membership_end_time,
      ignore_overlapping_reservations: @ignore_conflicts
    }
  end

  def membership_name(params)
    email = params[:email].present? ? params[:email] : t('no_email')
    "#{email}|#{date_desc(params)}|#{time_desc(params)}|#{court_desc(params)}|"
  end

  def court_desc(params)
    "#{params[:court_type]}#{params[:court_index]}(#{params[:court_sport]})"
  end

  def date_desc(params)
    "#{params[:start_date]}-#{params[:end_date]}, #{params[:weekday]}"
  end

  def time_desc(params)
    "#{params[:start_time]}-#{params[:end_time]}"
  end

  def sanitize_params(params)
    params[:email]        = params[:email].to_s.downcase
    params[:price]        = params[:price].to_f
    params[:court_index]  = params[:court_index].to_i
    params[:court_type]   = params[:court_outdoor].blank? ? :indoor : :outdoor
    params[:court_sport]  = params[:court_sport].to_s.downcase
    params[:weekday]      = params[:weekday].to_s.downcase

    params
  end
end
