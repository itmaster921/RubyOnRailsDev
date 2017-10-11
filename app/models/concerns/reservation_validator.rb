# Handles validating reservations
module ReservationValidator
  extend ActiveSupport::Concern

  MINUTE_DURATIONS = [-1, 30, 60, 120].freeze

  included do
    # used to bypass some validations for admin
    attr_accessor :update_by_admin

    validates :user, presence: true, associated: true
    validates :court, presence: true, associated: true
    validates :price, numericality: { greater_than_or_equal_to: 0 },
                      allow_nil: false, presence: true
    validates :start_time, presence: true
    validates :end_time, presence: true

    validate :timing_order
    validate :in_the_future, unless: :by_admin?
    validate :no_overlapping_reservations
    validate :not_on_offday
    validate :duration_policy, unless: :by_admin?
    validate :start_time_policy, unless: :by_admin?
    validate :date_limit_policy, unless: :by_admin?
    validate :court_active
  end

  def by_admin?
    admin? || update_by_admin
  end

  def timing_order
    return unless start_time.present? && end_time.present?

    if start_time && end_time && end_time < start_time
      errors.add(:end_time, I18n.t('errors.reservation.end_time.timing_order'))
    end
  end

  def in_the_future
    return unless start_time.present?

    if start_time < Time.current.utc
      errors.add(:start_time, I18n.t('errors.reservation.start_time.in_the_future'))
    end
  end

  def court_active
    return unless court.present?

    errors.add(:court,
               I18n.t('errors.reservation.court.closed')) unless court.active?
  end


  def no_overlapping_reservations
    return unless start_time.present? && end_time.present? && court.present?

    overlapping_reservations = get_overlapping_reservations
    if overlapping_reservations.any?
      full_name = overlapping_reservations.first.user.full_name
      errors.add(:overlapping_reservation, I18n.t('errors.reservation.overlapping', user_name: full_name.humanize))
    end
  end

  def not_on_offday
    return unless start_time.present? && end_time.present? && court.present?
    #return if membership?

    unless court.working?(start_time, end_time)
      errors.add('Court', I18n.t('errors.reservation.court.closed'))
      return false
    end
    true
  end

  def duration_policy
    return unless start_time.present? && end_time.present? && court.present?

    duration = (TimeSanitizer.input(end_time.to_s) - TimeSanitizer.input(start_time.to_s)) / 60

    if duration.to_i < Court.duration_policies[court.duration_policy].to_i
      errors.add(:duration_policy, I18n.t('errors.reservation.end_time.duration_problem'))
    end
  end

  def start_time_policy
    return unless start_time.present? && court.present?
    return if membership?

    case court.start_time_policy.to_sym
    when :hour_mark
      if start_time.min != 0
        errors.add(:start_time, I18n.t('errors.reservation.start_time.zero'))
      end
    when :half_hour_mark
      if start_time.min != 30
        errors.add(:start_time, I18n.t('errors.reservation.start_time.half'))
      end
    else
      true
    end
  end

  def date_limit_policy
    return unless start_time.present? && court.present?
    return if membership?

    unless court.venue.bookable?(start_time.to_date)
      errors.add(:start_time,
                 I18n.t('errors.reservation.start_time.days_in_advance',
                        limit: court.venue.booking_ahead_limit))
    end
  end
end
