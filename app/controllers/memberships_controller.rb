class MembershipsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_venue, except: [:csv_template]

  def index
    @memberships = @venue.memberships
    respond_to do |format|
      format.json do
        json = @memberships.map do |m|
          {
            start: m.start_time,
            end: m.end_time,
            user: m.user_id,
            venue: m.venue_id
          }
        end
        render json: json
      end
    end
  end

  def show
    @membership = Membership.find(params[:id])
  end

  def create
    tparams = MembershipTimeSanitizer.new(params[:membership]).time_params

    user = User.find_or_create_by_id(params[:user])
    membership = Membership.new(venue_id: params[:venue_id],
                                user: user,
                                start_time: tparams[:membership_start_time],
                                end_time: tparams[:membership_end_time],
                                price: params[:membership][:price])
    membership.ignore_overlapping_reservations = true if params[:ignore_overlapping_reservations]
    membership.make_reservations(tparams, params[:membership][:court_id])
    begin
      Membership.transaction do
        user.save!
        membership.save!
        unless @venue.users.include?(user)
          VenueUserConnector.create user: user, venue: @venue
        end
        ConfirmationMailer.confirmation_instructions(user,
                                                     user.confirmation_token,
                                                     {},
                                                     @venue)
                          .deliver_now unless params[:user][:user_id]
      end
      redirect_to memberships_path(@venue), notice: 'Created Membership...'
    rescue
      prev_params = params.select{ |k,v| [:venue_id, :membership, :user, :controller, :action].include? k.to_sym }.to_hash
      handle_overlapping_reservations(membership, prev_params)
      flash[:alert] = 'Membership could not be created'
      render template: 'venues/memberships'
    end
  end

  def update
    tparams = MembershipTimeSanitizer.new(params[:membership]).time_params
    membership = Membership.find(params[:id])
    membership.ignore_overlapping_reservations = true if params[:ignore_overlapping_reservations]
    if membership.handle_update(params[:membership], tparams)
      redirect_to memberships_path(@venue), notice: 'Updated Membership...'
    else
      prev_params = params.select{ |k,v| [:venue_id, :membership, :controller, :action].include? k.to_sym }.to_hash
      handle_overlapping_reservations(membership, prev_params)
      flash[:alert] = 'Membership could not be updated'
      render template: 'venues/memberships'
    end
  end

  def convert_to_cc
    membership = Membership.find(params[:id])
    plan = Stripe::Plan.create(
      :amount => (membership.price.*100).to_i,
      :interval => 'month',
      :interval_count => '1',
      :name => membership.venue.venue_name + ' ' + 'vakiovuoro',
      :currency => 'eur',
      :id => SecureRandom.uuid # This ensures that the plan is unique in stripe
    )
    customer = Stripe::Customer.retrieve(membership.user.stripe_id)
    stripe_subscription = customer.subscriptions.create(
      :plan => plan.id,
      )
    membership.update_attributes(invoice_by_cc: true, subscription_id: stripe_subscription.id)
    redirect_to :back, notice: "Onnistuneesti muutettu veloitus luottokortilta"
  end

  def destroy
    @membership = Membership.find(params[:id])
    @membership.handle_destroy
    redirect_to :back, notice: 'Membership deleted'
  rescue ActiveRecord::RecordNotFound
    redirect_to :back, alert: 'Membership not found!'
  end

  # post
  def import
    importer = CSVImportMemberships.new(params[:csv_file], @venue, params[:ignore_conflicts]).run
    @report_message = importer.report_message
    @failed_rows = importer.invalid_rows

    respond_to do |format|
      format.js
      format.html { redirect_to :back, notice: @report_message }
    end
  end

  def csv_template
    send_data CSVImportMemberships.csv_template, filename: "memberships_csv_template.csv"
  end

  private

  def membership_params
    params.require(:membership).permit(:start_time, :end_time,
                                       :user_id, :venue_id,
                                       :price)
  end

  def set_venue
    @venue = Venue.find(params[:venue_id])
  end

  def handle_overlapping_reservations(membership, prev_params)
    @ignore_overlaps_url = url_for(prev_params.merge({ignore_overlapping_reservations: true}))
    @bad_reservations = membership.reservations.reject(&:valid?)
    @memberships = membership.venue.memberships.includes(:user)
    @reservations = Reservation.reservations_for_memberships(@memberships.map(&:id))
  end
end
