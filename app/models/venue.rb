# Reperesnts a sports venue
class Venue < ActiveRecord::Base
  include BusinessHours
  include VenueTimeFrames
  include Listable
  include VenueGenerateXls
  include CustomColors

  MAX_COURT_INDEX = 30

  store :business_hours, coder: Hash
  store :court_counts, coder: Hash

  belongs_to :company
  has_many :courts, dependent: :destroy
  has_many :venue_user_connectors
  has_many :reservations, through: :courts
  has_many :prices, through: :courts
  has_many :photos, dependent: :destroy
  has_one :primary_photo, class_name: 'Photo'
  has_many :users, through: :venue_user_connectors
  has_many :day_offs, as: :place, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :discounts, dependent: :destroy
  has_many :email_lists
  has_many :game_passes, dependent: :destroy

  before_create :set_counts

  WEEKDAYS = [:monday, :tuesday,
              :wednesday, :thursday,
              :friday, :saturday,
              :sunday].freeze

  accepts_nested_attributes_for :courts, :prices, :reservations

  geocoded_by :venue_address
  after_validation :geocode, if: :venue_address_changed?

  validates :venue_name, presence: true
  validates :description, presence: true
  # validates :parking_info, presence: true
  # validates :transit_info, presence: true
  # validates :website, presence: true
  # validates :phone_number, presence: true
  # validates :monday_opening_time, presence: true
  # validates :tuesday_opening_time, presence: true
  # validates :wednesday_opening_time, presence: true
  # validates :thursday_opening_time, presence: true
  # validates :friday_opening_time, presence: true
  # validates :saturday_opening_time, presence: true
  # validates :sunday_opening_time, presence: true
  # validates :monday_closing_time, presence: true
  # validates :tuesday_closing_time, presence: true
  # validates :wednesday_closing_time, presence: true
  # validates :thursday_closing_time, presence: true
  # validates :friday_closing_time, presence: true
  # validates :saturday_closing_time, presence: true
  # validates :sunday_closing_time, presence: true
  validates :booking_ahead_limit, presence: true
  validate :listable?, if: 'listed_changed?(from: false, to: true)'

  scope :listed, -> { where(listed: true) }
  scope :sport, ->(sport) {
    where(id: Court.where(sport_name: Court.sport_names[sport]).select(:venue_id).distinct )
  }

  def self.tennis
    Venue.listed.select {|v| v.supported_sports.include?("tennis")}
  end

  def self.padel
    Venue.listed.select {|v| v.supported_sports.include?("padel")}
  end

  def supported_sports
    # TODO(aytigra): This block doesn't actually work, needs check for dependency and cleanup
    self.courts.map(&:sport_name).uniq.compact do |sport|
      [Court.human_attribute_name("sport_name.#{sport}"), sport]
    end
  end

  def supported_sports_options
    supported_sports.map do |sport|
      { value: sport, label: Court.human_attribute_name("sport_name.#{sport}") }
    end
  end

  def custom_sports
    self.courts.map(&:custom_sport_name).uniq.compact do |sport|
      [sport, sport]
    end
  end

  def supported_and_custom_sports
    supported_sports + custom_sports
  end

  def supported_surfaces
    self.courts.map(&:surface).uniq.compact
  end

  def courts_by_surface_json(surface)
    courts.select { |court| !court.active? && court.surface == surface}
      .map do |court|
        {
          start: Time.zone.today.at_beginning_of_day,
          end: (Time.zone.today + 10.years).at_end_of_day,
          resourceId: court.id
        }
      end
  end

  def self.all_sport_names
    path = "sport_icons"
    result = []
    Venue.all.includes(:courts).map(&:supported_sports).flatten.uniq.each do |sport_name|
      hsh = {}
      hsh['name'] = sport_name
      hsh['url_active'] = ActionController::Base.helpers.asset_path("#{path}/active/#{sport_name}.svg")
      hsh['url_inactive'] = ActionController::Base.helpers.asset_path("#{path}/inactive/#{sport_name}.svg")
      result.push(hsh)
    end
    result
  end

  def track_bookings(venue_id, reservation_id, user_id)
    tracker = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"])
    reservation = Reservation.find(reservation_id)
    user = User.find(user_id)
    first_res_time = nil
    if user.reservations.count == 1
      first_res_time = reservation.created_at
    end
    tracker.track(
      user_id,
      "Paid Booking Done By User",
      {
        venue_id: venue_id,
        venue_name: Venue.find(venue_id).venue_name,
        reservation_id: reservation_id,
        first_reservation_timestamp: (Time.parse(reservation.created_at.to_s) - Time.parse(reservation.user.created_at.to_s)).round,
        price: reservation.price,
        court_id: reservation.court_id
      }
    )
  rescue
  end

  def track_unpaid_bookings(venue_id, reservation_id, user_id)
    tracker = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    reservation = Reservation.find(reservation_id)
    user = User.find(user_id)
    first_res_time = nil
    if user.reservations.count == 1
      first_res_time = reservation.created_at
    end
    tracker.track(
      user_id,
      "Unpaid Booking Done By User",
      {
        venue_id: venue_id,
        venue_name: Venue.find(venue_id).venue_name,
        reservation_id: reservation_id,
        first_reservation_timestamp: (Time.parse(reservation.created_at.to_s) - Time.parse(reservation.user.created_at.to_s)).round,
        price: reservation.price,
        court_id: reservation.court_id
      }
    )
  rescue
  end

  def map_users
    # why not self.users ?
    users = self.users.map do |u|
      {
        name: u.try(:full_name),
        id: u.id,
        email: u.try(:email)
      }
    end
    users.index_by { |r| r[:id] }.values
  end

  def self.reservation_data_for_collection(venues, time, duration, sport_name)
    venues.map do |venue|
      reservations = venue.get_reservation_data_around(time, duration,
                                                       sport_name)
      {
        id: venue.id, photos: venue.photos,
        reservations: reservations, venue_lowest: venue_lowest(reservations),
        name: venue.venue_name
      }
    end
  end

  def self.venue_lowest(reservations)
    reservations.map { |r| r.second['lowest_price'] }.min
  end
  private_class_method :venue_lowest

  def image_urls
    images = photos.map(&:image)
    images.map(&:url)
  end

  def venue_address_changed?
    city_changed? || zip_changed? || street_changed?
  end

  def venue_address
    "#{street}, #{city} #{zip}"
  end

  # get days of venue and all individual courts
  def all_offdays
    offdays = []
    self.courts.includes(:day_offs).each do |c|
      offdays = offdays + c.day_offs
    end
    offdays = offdays + self.day_offs
  end

  def offdays_as_json
    offdays = day_offs.map do |offday|
      offday.jsonify
    end
    courts.includes(:day_offs).each do |c|
      offdays += c.offdays_as_json
    end
    offdays
  end

  def booking_date_limit
    Date.current + booking_ahead_limit.days
  end

  def active_courts_json
    courts.reject(&:active?)
          .map do |court|
            {
              start: Time.zone.today.at_beginning_of_day,
              end: (Time.zone.today + 10.years).at_end_of_day,
              resourceId: court.id
            }
          end
  end

  # check that date can be booked while respecting booking ahead limit
  def bookable?(date)
    date < booking_date_limit
  end

  def set_counts
    self.court_counts = {
      indoor: {},
      outdoor: {}
    }
  end

  def set_primary_photo
    new_primary = photos.first.id unless photos.empty?
    update_attributes(primary_photo_id: new_primary)
  end

  def primary_photo
    Photo.find(primary_photo_id) unless primary_photo_id.nil?
  end

  def try_photo_url
    photos.first.try(:image).try(:url)
  end

  def add_customer(user)
    unless users.include?(user)
      VenueUserConnector.create(user: user, venue: self)
    end
  end

  def available_court_indexes(search_params, exept_id, number_of_consecutive = 1)
    return [] if search_params[:indoor] === nil ||
                 search_params[:sport_name].blank? &&
                  search_params[:custom_sport_name].blank?

    if search_params[:custom_sport_name].blank?
      search_params[:custom_sport_name] = nil
    end
    search_params[:venue] = self

    taken_indexes = Court.where(search_params).where.not(id: exept_id).pluck(:index)

    available_indexes = (1..MAX_COURT_INDEX).to_a - taken_indexes

    MathExtras.start_with_consecutive(available_indexes, number_of_consecutive)
  end

  def has_shared_courts?
    courts.each do |court|
      return true if court.shared_courts.any?
    end
    false
  end

  # returns map with court_id as key and array of shared courts as values
  def shared_courts_map
    shared_courts_map = {}
    courts.each do |court|
      shared_courts_map[court.id] = court.shared_courts
    end
    shared_courts_map
  end

  # returns actual reservations along with their copies for shared courts
  # to indicate bookings in shared courts
  def reservations_shared_courts_json(start_date, end_date)
    reservations_json = reservations_between_dates(start_date, end_date).map do |r|
      r.as_json_for_calendar(id)
    end

    if has_shared_courts?
      shared_courts_hash = shared_courts_map
      shared_reservations_json = reservations_json.map do |r|
        shared_courts_hash[r[:resourceId]].map do |shared_court|
          resv_court = Court.find(r[:resourceId])
          r_copy = r.dup
          r_copy[:title] += " - #{resv_court.court_name} (#{resv_court.sport_name})"
          r_copy[:resourceId] = shared_court.id
          r_copy
        end
      end.flatten
    end
    reservations_json + shared_reservations_json.to_a
  end

  def reservations_between_dates(start_date, end_date)
    reservations.includes(:user).where('start_time >= ? and start_time < ?',
                       start_date, end_date)
  end

  def available_game_passes(user_id, court_id, start_time, end_time)
    game_passes.
      usable.
      where(user_id: user_id).
      available_for_court(Court.find_by_id(court_id)).
      available_for_date(start_time.to_date, end_time.to_date).
      to_a.
      select { |gp| gp.usable_at?(start_time, end_time) }
  end
end
