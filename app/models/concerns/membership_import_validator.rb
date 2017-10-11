module MembershipImportValidator
  extend ActiveSupport::Concern

  DEFAULT_WEEKDAYS = %w(monday tuesday wednesday thursday friday saturday sunday).freeze

  # non persistent attributes
  attr_writer :importing
  attr_accessor :import_data, :court

  included do
    before_validation :find_user, if: :importing?

    validate :validate_weekday, if: :importing?
    validate :validate_court_sport, if: :importing?
    validate :validate_court, if: :importing?
    validate :validate_already_imported, if: :importing?
    # it should run between this validations and associations validations
    validate :make_reservations_for_validation, if: :importing?
  end

  def importing?
    @importing == true
  end

  def already_imported?
    errors.include?(:already_imported)
  end

  private

  def find_user
    self.user = User.where(email: import_data[:email]).take
  end

  def validate_weekday
    raw_weekday = import_data[:weekday]
    self.import_data[:weekday] = nil
    # find if it is a default weekday or translation of such
    DEFAULT_WEEKDAYS.each do |default_weekday|
      if raw_weekday == default_weekday ||
          raw_weekday == I18n.t("weekdays.#{default_weekday}")
        self.import_data[:weekday] = default_weekday
        break
      end
    end

    unless import_data[:weekday].present?
      errors.add(:weekday, t_error('weekday', weekday: raw_weekday))
    end
  end

  def validate_court_sport
    raw_sport = import_data[:court_sport]
    self.import_data[:court_sport] = nil
    # find if it is a default sport or translation of such
    Court.sport_names.keys.each do |default_sport|
      if raw_sport == default_sport ||
          raw_sport == translate_sport(default_sport)
        self.import_data[:court_sport] = default_sport
        break
      end
    end

    unless import_data[:court_sport].present?
      defaults = Court.sport_names.keys.join(', ')
      errors.add(:court_sport, t_error('court_sport', sport: raw_sport,
                                                      defaults: defaults))
    end
  end

  def validate_court
    return if errors.any?

    self.court = venue.courts.where(sport_name: import_data[:court_sport],
                        indoor: import_data[:court_type] == :indoor,
                        index: import_data[:court_index],
                        custom_sport_name: nil).take

    unless court.present?
      court_name = import_data[:court_type].to_s +
                    import_data[:court_index].to_s +
                    "(#{import_data[:court_sport]})"
      errors.add(:court, t_error('no_court', name: court_name))
    end
  end

  def validate_already_imported
    return if errors.any?

    similar_membership = Membership.where(venue: venue, user: user,
                                          price: price,
                                          start_time: start_time,
                                          end_time: end_time
                                          ).take

    similar_reservation = similar_membership.try(:reservations).try(:first)

    # either similar membership without reservaions,
    # or similar membership with similar reservations(court, weekday)
    if similar_membership &&
        (!similar_reservation ||
          similar_reservation.court_id = court.id &&
          similar_reservation.start_time.strftime('%A') ==
            import_data[:weekday].capitalize)

      errors.add(:already_imported, '')
    end
  end

  def make_reservations_for_validation
    return if errors.any?

    tparams = MembershipTimeSanitizer.new(import_data).time_params

    self.make_reservations(tparams, court.id)
  end

  def translate_sport(name)
    Court.human_attribute_name("sport_name.#{name}").downcase
  end

  def t_error(name, params = {})
    I18n.t("errors.membership.#{name}", params)
  end
end
