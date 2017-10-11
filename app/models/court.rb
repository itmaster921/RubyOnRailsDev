# represents one court in a sports venue
class Court < ActiveRecord::Base
  include Pricing

  belongs_to :venue
  has_many :dividers, dependent: :destroy
  has_many :prices, through: :dividers
  has_many :reservations, dependent: :destroy
  has_many :day_offs, as: :place, dependent: :destroy
  has_many :court_connectors, dependent: :destroy
  has_many :shared_courts, through: :court_connectors

  validates :sport_name, presence: true
  validates :duration_policy, presence: true
  validates :start_time_policy, presence: true
  validates :venue, presence: true

  before_save :court_index, if: 'name_changed?'

  enum duration_policy: { any_duration: -1,
                          one_hour: 60,
                          two_hour: 120 }
  enum start_time_policy: [:any_start_time, :hour_mark, :half_hour_mark]
  enum sport_name: [:tennis, :squash, :badminton, :golf, :volleyball, :soccer, :floorball, :tabletennis]
  enum surface: [:other, :hard_court, :red_clay, :green_clay, :artificial_clay, :grass, :artificial_grass, :concrete, :asphalt, :carpet]

  scope :active, -> { where(active: true) }
  scope :common, -> { where custom_sport_name: nil }
  scope :custom, -> { where.not custom_sport_name: nil }

  def to_s
    court_name
  end

  def price_at(start_time, end_time, discount = nil)
    start_time = TimeSanitizer.output(start_time)
    end_time = TimeSanitizer.output(end_time)

    final_price = prices.map { |p| p.apply(start_time, end_time) }.sum

    discount.is_a?(Discount) ? discount.apply(final_price) : final_price
  end

  # shoul have price rules covering whole timeslot
  def has_price?(start_time, end_time)
    start_minute = TimeSanitizer.output(start_time).minute_of_a_day
    end_minute = TimeSanitizer.output(end_time).minute_of_a_day
    day = TimeSanitizer.output(start_time).strftime('%A').to_s.downcase.to_sym

    MathExtras.substract_ranges(
      [[start_minute, end_minute]],
      prices_timeranges(start_minute, end_minute, day)
    ).length == 0
  end

  def prices_timeranges(start_minute, end_minute, day)
    prices.map do |p|
      if p.applies_to?(start_minute, end_minute, day)
        [p.start_minute_of_a_day, p.end_minute_of_a_day]
      end
    end.compact
  end

  def reservations_during(start_time, end_time)
    started = reservations.where(start_time: (start_time - 1.minute)..(end_time + 1.minute))
    ended = reservations.where(end_time: start_time..end_time)
    between = reservations.where('start_time <= ?', start_time)
                          .where('end_time >= ?', end_time)
    started + ended + between
  end

  def offdays_as_json
    day_offs.map do |offday|
      json_offday = offday.jsonify
      json_offday[:resourceId] = id
      json_offday
    end
  end

  # naive way find better way for cover
  def working?(start_time, end_time)
    return false unless venue.in_business?(start_time, end_time)
    day_offs.each do |dayoff|
      return false if dayoff.covers?(start_time, end_time)
    end
    true
  end

  def bookable?(start_time, end_time, price)
    Reservation.new(start_time: start_time,
                    end_time:   end_time,
                    court:      self,
                    price:      price,
                    user:       User.new,
                    booking_type: :online).valid?
  end

  def can_start_at?(time)
    not (start_time_policy == "half_hour_mark" && time.min != 30 ||
         start_time_policy == "hour_mark" && time.min != 0)
  end

  def court_name
    type = indoor ? 'indoor' : 'outdoor'
    name = Court.human_attribute_name("court_name.#{type}")

    name = custom_sport_name if custom_sport_name.present?

    "#{name} #{index}"
  end

  def sport
    if custom_sport_name.present?
      Court.human_attribute_name("sport_name.private")
    else
      Court.human_attribute_name("sport_name.#{sport_name}")
    end
  end

  # important for :common scope
  def custom_sport_name=(string)
    string = nil if string.blank?
    super
  end

  def self.supported_sports
    sport_names.keys.map do |sport|
      [Court.human_attribute_name("sport_name.#{sport}"), sport]
    end
  end

  def self.all_surfaces
    surfaces.keys.map do |surface|
      [Court.human_attribute_name("surface.#{surface}"), surface]
    end
  end

  def as_json(options)
    court = super(options)
    court[:court_name] = court_name
    court[:sport] = sport
    court
  end

  private

  def get_weekday(date)
    date.strftime('%A').to_s.downcase.to_sym if date
  end

  def court_index
    available_indexes = venue.available_court_indexes({
      indoor: indoor,
      sport_name: self.class.sport_names[sport_name],
      custom_sport_name: custom_sport_name,
      }, id)

    self.index = available_indexes.first unless available_indexes.include?(index)
  end

  def name_changed?
    sport_name_changed? ||
      custom_sport_name_changed? ||
      indoor_changed? ||
      !persisted?
  end
end
