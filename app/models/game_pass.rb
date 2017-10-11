class GamePass < ActiveRecord::Base
  default_scope { where template_name: nil }

  DAYS = %w(sun mon tue wed thu fri sat).freeze
  # { limits: [{ from: 420, to: 810, weekdays: ['mon', 'wed'] }, ...] }
  store :time_limitations, coder: Hash

  enum court_type: [:any, :indoor, :outdoor]

  belongs_to :user
  belongs_to :venue
  scope :invoicable, -> { where(is_billed: false, is_paid: false) }
  validates :user, presence: true, unless: :template?
  validates :venue, presence: true

  scope :templates, -> { unscoped.where.not template_name: nil }
  scope :usable, -> { where(active: true, is_paid: true).where(arel_table[:remaining_charges].gt(0)) }

  scope :available_for_court, ->(court) do
    where(arel_table[:court_sports].eq(nil)
            .or(arel_table[:court_sports].matches("%#{court.sport_name}%"))
    ).where(arel_table[:court_type].eq(0)
            .or(arel_table[:court_type].eq(court.indoor? ? 1 : 2))
    )
  end

  scope :available_for_date, ->(start_date, end_date) do
    t = arel_table
    dates_scope = t[:start_date].lteq(start_date)
                      .or(t[:start_date].eq(nil))
                    .and(t[:end_date].gteq(end_date)
                      .or(t[:end_date].eq(nil)))

    where(dates_scope)
  end

  def template?
    self.template_name.present?
  end

  def usable?
    active? && remaining_charges > 0
  end

  def use!
    update!(remaining_charges: remaining_charges - 1) if usable?
  end

  def usable_at?(start_time, end_time)
    return true unless limits.any?
    weekday = start_time.strftime('%a').downcase

    limits.any? do |limit|
      limit[:from] <= start_time.minute_of_a_day &&
        limit[:to] >= end_time.minute_of_a_day &&
        (limit[:weekdays].blank? || limit[:weekdays].to_a.include?(weekday))
    end
  end

  # return [{ from: '07:00', to: '13:30', weekdays: ['mon', 'wed'] }, ...]
  def time_limitations
    limits.map do |limit|
      date = Date.current.beginning_of_year # safe date
      from = TimeSanitizer.add_minutes(date, limit[:from]).to_s(:time)
      to   = TimeSanitizer.add_minutes(date, limit[:to]).to_s(:time)

      { from: from, to: to, weekdays: limit[:weekdays].to_a }
    end
  end

  # parse [{ from: '07:00', to: '13:30', weekdays: ['mon', 'wed'] }, ...]
  def time_limitations=(raw_limits)
    limits = []
    raw_limits.to_a.each do |limit|
      limit = limit.to_h.with_indifferent_access
      next unless limit[:from].present? && limit[:to].present?

      from = TimeSanitizer.output_input("01/01/2017 #{limit[:from]}")
                          .minute_of_a_day
      to   = TimeSanitizer.output_input("01/01/2017 #{limit[:to]}")
                          .minute_of_a_day

      weekdays = []
      limit[:weekdays].to_a.each do |day|
        day = day.to_s.strip
        weekdays << day if DAYS.include?(day)
      end

      limits << {from: from, to: to, weekdays: weekdays}
    end

    asign_limits limits
  end

  def court_sports
    self[:court_sports].to_s.split(',')
  end

  def court_sports=(raw_sports)
    sports = []

    raw_sports.to_a.each do |sport|
      sport = sport.strip.downcase

      sports << sport if Court.sport_names.keys.include?(sport)
    end

    self[:court_sports] = sports.any? ? sports.join(',') : nil
  end

  def court_type=(type)
    type = 0 if type.blank?
    super(type)
  end

  def self.court_types_options
    court_types.keys.map do |type|
      { value: type, label: Court.human_attribute_name("court_name.#{type}") }
    end
  end

  def court_sports_to_s
    if court_sports.any?
      court_sports.map do |sport|
        Court.human_attribute_name("sport_name.#{sport}")
      end.join(', ')
    else
      Court.human_attribute_name("sport_name.any")
    end
  end

  def start_date_to_s
    start_date.present? ? start_date.to_s(:date) : ''
  end

  def end_date_to_s
    end_date.present? ? end_date.to_s(:date) : ''
  end

  def dates_limit
    unlimited = I18n.t('unlimited')

    if start_date && end_date
      "#{start_date_to_s} - #{end_date_to_s}"
    elsif start_date
      "#{start_date_to_s} - #{unlimited}"
    elsif end_date
      "#{unlimited} - #{end_date_to_s}"
    else
      unlimited
    end
  end

  def time_limitations_to_s
    return I18n.t('unlimited') if time_limitations.empty?

    time_limitations.map do |limit|
      weekdays = limit[:weekdays].map { |wday| I18n.t("weekdays_short.#{wday}") }
      weekdays = weekdays.any? ? "(#{weekdays.join(', ')})" : ''

      "#{limit[:from]}-#{limit[:to]}#{weekdays}"
    end.join(', ')
  end

  # for template return either name or template name, to use as template
  def name
    return self.template_name if self[:name].blank? && template?

    self[:name].to_s
  end

  # when at least some name is needed
  def auto_name
    charges = "#{remaining_charges}/#{total_charges}"

    return "#{charges} #{self.name}" if self.name.present?

    type  = Court.human_attribute_name("court_name.#{court_type}")

    "#{charges}|#{court_sports_to_s}|#{type}|#{dates_limit}|#{time_limitations_to_s}"
  end

  private

  def limits
    self[:time_limitations][:limits].to_a
  end

  def asign_limits(limits)
    self[:time_limitations][:limits] = limits
    self[:time_limitations][:limits].uniq!
  end
end
