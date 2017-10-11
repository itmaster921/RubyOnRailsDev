# Represents a user recurring membership
class Membership < ActiveRecord::Base
  include MembershipImportValidator

  belongs_to :user
  belongs_to :venue
  has_many :reservations, through: :membership_connectors, dependent: :destroy
  has_many :membership_connectors, dependent: :destroy

  validates :venue, presence: true
  validates :user, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 },
                    allow_nil: false, presence: true
  validate :timing_order

  # ignore_overlapping_reservations is a non persistent attribute
  attr_accessor :ignore_overlapping_reservations

  def make_reservations(tparams, court_id)
    while tparams[:start_time].to_date <= tparams[:membership_end_time]
      tparams = create_reservation(court_id, tparams)
    end
  end

  def handle_destroy
    destroy_future_reservations
    membership_connectors.delete_all
    destroy
  end

  def handle_update(membership_params, tparams)
    assign_attributes(start_time: tparams[:membership_start_time],
                      end_time: tparams[:membership_end_time],
                      price: membership_params[:price])
    commit_update(tparams, membership_params)
  end

  private

  def destroy_future_reservations
    reservations.select { |r| r.start_time > Time.now.utc }.reject(&:resold?).each(&:destroy)
    reservations.reload
  end

  def log_reservation(resv)
    logger.debug "#{resv.start_time} #{resv.end_time}"
    logger.debug resv.valid?.to_s
    logger.debug resv.errors.full_messages
  end

  def advance_time(tparams)
    tparams[:start_time] = advance_time!(tparams[:start_time])
    tparams[:end_time] = advance_time!(tparams[:end_time])
    tparams
  end

  # reservations start time is changed to local time
  # to be advanced properly (this handles problems with
  # equinox)
  def advance_time!(time)
    TimeSanitizer.input(TimeSanitizer.output(time).advance(days: 7).to_s)
  end

  def create_reservation(court_id, tparams)
    if tparams[:start_time] >= Time.now.utc
      resv = reservations.build(user: user, price: price,
                                court_id: court_id,
                                start_time: tparams[:start_time],
                                end_time: tparams[:end_time],
                                payment_type: :unpaid,
                                booking_type: :membership)
      log_reservation(resv)
      handle_overlapping_reservation(resv)
      tracker = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"])
      court = Court.find(court_id)
      venue = court.venue
      user = User.find(resv.user_id)
      tracker.track(
        user.id,
        "Reoccurring reservation",
        {
          venue_id: venue.id,
          venue_name: venue.venue_name,
          price: resv.price,
          court_id: resv.court_id
        }
      )
    end
    advance_time(tparams)
  end

  def handle_overlapping_reservation(reservation)
    if self.ignore_overlapping_reservations && reservation.invalid? &&
      (reservation.errors.messages.count > 0)

      reservation.destroy
    end
  end

  def commit_update(tparams, membership_params)
    Membership.transaction do
      destroy_future_reservations
      reservations.reload
      make_reservations(tparams, membership_params[:court_id])
      save!
    end
    true
  rescue
    false
  end

  # validates if membership start_time is lesser than end_time
  def timing_order
    if start_time && end_time && end_time < start_time
      errors.add(:end_time, "end_time should be greater than start_time")
    end
  end
end
