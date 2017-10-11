# Represents a user continous reservation of a court
# for a certain amount of time
class Reservation < ActiveRecord::Base
  include ReservationValidator
  include ReservationLogging

  default_scope { where inactive: false }

  attr_accessor :game_pass_id, :skip_booking_mail

  belongs_to :court
  belongs_to :user, polymorphic: true
  has_many :invoice_components, dependent: :destroy
  has_one :membership_connector, dependent: :destroy
  has_one :membership, through: :membership_connector
  has_many :logs, class_name: 'ReservationsLog', inverse_of: :reservation, foreign_key: :reservation_id, dependent: :destroy

  scope :past, -> { where('start_time < ?', TimeSanitizer.output(Time.now)) }
  scope :future, -> { where('start_time > ?', TimeSanitizer.output(Time.now)) }
  scope :reselling, -> { where(reselling: true) }
  scope :recurring, -> { joins(:membership_connector) }
  scope :non_recurring, -> { joins(mc_left_join_sql).where(membership_connectors: { id: nil }) }
  scope :include_venues, -> { includes(court: { venue: :photos }) }

  scope :invoicable, -> { where(is_billed: false, is_paid: false) }
  enum booking_type: [:online, :admin, :membership, :guest]
  enum payment_type: [:paid, :unpaid, :semi_paid]

  before_save :set_payment_type,
              unless: 'paid?'

  after_create :booking_mail, unless: 'skip_booking_mail'
  after_create :write_log
  after_update :write_log
  after_save   :resold_untie_membership

  def self.mc_left_join_sql
    mct = MembershipConnector.arel_table
    arel_table.outer_join(mct).on(arel_table[:id].eq(mct[:reservation_id])).join_sources
  end

  def self.on_date(date)
    t = arel_table
    start_time = TimeSanitizer.output(date).at_beginning_of_day
    end_time   = TimeSanitizer.output(date).at_end_of_day + 1.second

    where t[:start_time].gteq(start_time).and(t[:end_time].lteq(end_time))
  end

  def skip_booking_mail!
    self.skip_booking_mail = true
  end

  def booking_mail
    BookingMailer.booking_email(user, self)
                 .deliver_now unless user_type == 'Guest' || membership?
  end

  def track_booking
    if online?
      MixpanelTracker.booking(court.venue, self, user) if paid?
      MixpanelTracker.unpaid_booking(court.venue, self, user) if unpaid?
    elsif admin?
      MixpanelTracker.booking(court.venue, self, user, 'Admin') if paid?
      MixpanelTracker.unpaid_booking(court.venue, self, user, 'Admin') if unpaid?
    end
  rescue
  end

  # refund without reverse_transfer option takes the money from our
  # account. Create the refund explicitly with amount and reverse_transfer
  def stripe_refund
    return if refunded || !charge_id.present?
    charge = Stripe::Charge.retrieve(charge_id)
    charge.refunds.create(amount: charge.amount, reverse_transfer: true)
    update_attributes(refunded: true, is_paid: false, is_billed: false, charge_id: nil)
  rescue Exception => e
    p "Stripe refund failed. Error => #{e.message}."
    logger.debug "Stripe refund failed. Error => #{e.message}."
  end

  def cancellation_email
    CancellationMailer.cancellation_email(user, self)
                      .deliver_now! unless user_type == 'Guest'
  end

  def get_overlapping_reservations
    t = self.class.arel_table
    # `start_time` >= {start_time} AND `start_time` < {end_time} OR
    #   `end_time` > {start_time} AND `end_time` <= {end_time} OR
    #   `start_time` <= {start_time} AND `end_time` >= {end_time}
    time_intersects = t[:start_time].gteq(start_time).and(t[:start_time].lt(end_time))
      .or(t[:end_time].gt(start_time).and(t[:end_time].lteq(end_time)))
      .or(t[:start_time].lteq(start_time).and(t[:end_time].gteq(end_time)))

    court_ids = CourtConnector.where(court_id: court_id).pluck(:shared_court_id) << court_id
    Reservation.where(court_id: court_ids).where(time_intersects).where.not(id: id)
  end

  def overlapping?(starts, ends)
    # exactly matching reselling reservation can be booked
    if start_time == starts && end_time == ends && reselling
      return false
    end

    start_time >= starts && start_time < ends  ||
      end_time > starts && end_time <= ends    ||
      start_time <= starts && end_time >= ends
  end

  def resold?
    initial_membership_id.present?
  end

  def recurring?
    membership.present? && !resold?
  end

  def future?
    start_time > Time.now.utc
  end

  def resellable?
    future? && recurring?
  end

  def cancelable?
    ((start_time - Time.now.utc) / 1.hour) > court.venue.cancellation_time
  end

  def refundable?
    cancelable? && charge_id.present? && !refunded
  end

  def cancel
    if resold?
      pass_back_to_initial_owner
    else
      update_attribute(:inactive, true)
    end
  end

  # finds reselling reservation with matching time/court
  # assigns to user and converts into normal reservation
  # makes it reversible by initial_membership_id
  # generally used as @rsrv = Reservation.new(params).take_matching_resell
  def take_matching_resell
    resell = Reservation.reselling.where(start_time: start_time, end_time: end_time, court: court).take
    if resell && resell.resellable?
      resell.assign_attributes( price: price,
                                booking_type: 0,
                                reselling: false,
                                user: user,
                                initial_membership_id: resell.membership.id)
      resell
    else
      self
    end
  end

  # assigns reselling recurring reservation to new user and convert into normal reservation
  # makes it reversible by initial_membership_id
  def resell_to_user(new_owner)
    return false unless reselling? && recurring? && new_owner.is_a?(User) && new_owner != user

    update_attributes(booking_type: 0,
                      reselling: false,
                      user: new_owner,
                      initial_membership_id: membership.id)
  end

  # converts resold reservation back to reselling recurring resevation
  # returns to initial owner and membership
  def pass_back_to_initial_owner
    initial_membership = Membership.find(initial_membership_id)
    update_attributes(  price: initial_membership.price,
                        booking_type: 2,
                        reselling: true,
                        user: initial_membership.user,
                        initial_membership_id: nil,
                        membership: initial_membership,
                        refunded: false)
  end

  def to_ics
    event = Icalendar::Event.new
    event.dtstart = TimeSanitizer.output(start_time)
    event.dtend = TimeSanitizer.output(end_time)
    event.summary = court.sport_name + ' at ' + court.venue.venue_name
    event.description = court.sport_name
    event.location = court.venue.street + ' ' + court.venue.zip + ' ' + court.venue.city
    event.created = created_at
    event.last_modified = updated_at
    event
  end

  # try to pay with card or mark as unpaid
  # should be used only for saved reservation
  def charge(token)
    charge = Stripe::Charge.create(charge_params(token))
    update_attributes(is_billed: true,
                      is_paid: true,
                      charge_id: charge.id)
    nil
  rescue Stripe::CardError => e
    update_attributes(is_billed: false,
                      is_paid: false,
                      payment_type: :unpaid)
    e.json_body[:error][:message]
  end

  # use game pass if available and mark as paid
  # or pass to payment
  # should be used only for saved reservation
  def use_game_pass_or_pay(token)
    # game_pass_id was set with params
    game_pass = GamePass.find_by_id(game_pass_id)

    if game_pass && game_pass_available?(game_pass)
      game_pass.use!
      update_attributes(is_paid: true, amount_paid: price)
    else
      charge(token)
    end
  end

  def game_pass_available?(game_pass)
    court.
      venue.
      available_game_passes(user_id, court_id, start_time, end_time).
      include?(game_pass)
  end

  def description
    "#Reservation: #{court.court_name} at #{court.venue.venue_name} for $#{price}"
  end

  def set_payment_type
    self.amount_paid ||= 0
    self.payment_type = if amount_paid >= price
                          :paid
                        elsif amount_paid > 0
                          :semi_paid
                        else
                          :unpaid
                        end
  end

  def color
    if court && court.venue
      colors = court.venue.custom_colors
    else
      colors = Venue::DEFAULT_COLORS
    end

    if reselling? && colors[:reselling]
      colors[:reselling]
    elsif membership? && colors[:membership]
      colors[:membership]
    elsif is_billed && !paid? && colors[:invoiced]
      colors[:invoiced]
    elsif paid? || is_billed
      colors[:paid]
    elsif unpaid?
      colors[:unpaid]
    elsif semi_paid?
      colors[:semi_paid]
    else
      colors[:other]
    end
  end

  def amount_paid
    # TODO(aytigra): properly convert to decimal in DB
    self[:amount_paid].to_f.to_d
  end

  # returns non nil outstanding balance
  def outstanding_balance
    if paid? then 0
    else price - amount_paid
    end
  end

  # returns non nil amount_paid
  def get_amount_paid
    if paid? then price
    else amount_paid
    end
  end

  def get_payment_method
    if paid?
      charge_id.present? ? I18n.t('reservations.online') : I18n.t('reservations.at_venue')
    elsif is_billed
      I18n.t('reservations.invoiced')
    else
      I18n.t('reservations.unpaid')
    end
  end

  def calculate_vat
    price - calculate_price_without_vat
  end

  def calculate_price_without_vat
    (price / (1 + court.venue.company.get_vat_decimal)).round(2)
  end

  # returns reservation event json for full calendar
  def as_json_for_calendar(venue_id)
    {
      id: id,
      start: TimeSanitizer.output(start_time),
      end: TimeSanitizer.output(end_time),
      price: price,
      title: "#{user.try(:full_name)}",
      resourceId: court_id,
      color: color,
      url: "/venues/#{venue_id}/reservations/#{id}"
    }
  end

  def self.reservations_for_memberships(membership_ids)
    select = 'reservations.*, membership_connectors.membership_id as membershipid'
    @reservations = Reservation.joins(:membership_connector).select(select)
                   .where(membership_connectors: { membership_id: membership_ids } ).includes(:court)
                   .group_by(&:membershipid)
  end

  def logged_courts
    courts_ids = logs.map { |log_entry| log_entry.params[:court_id] }
    Court.where(id: courts_ids.compact.uniq)
  end

  def recalculate_price
    discount = user.is_a?(User) ? user.discounts.where(venue: court.venue).first : nil

    update(price: court.price_at(start_time, end_time, discount))
  end

  private

  # untie resold reservation from mebership only after booking completion(after update)
  def resold_untie_membership
    if initial_membership_id_changed? && initial_membership_id && membership_connector.present?
      membership_connector.delete
    end
  end

  def charge_params(token)
    {
      amount: price.to_int * 100,
      currency: 'eur',
      source: token,
      customer: user.stripe_id,
      description: description,
      destination: court.venue.company.stripe_user_id
    }
  end
end
