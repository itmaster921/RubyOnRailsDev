class ReservationsController < ApplicationController
  before_action :authenticate_admin!, except: [:show, :refund, :index, :cancel, :resell]
  before_action :set_venue, except: [:index, :refund, :cancel, :resell, :show_log]

  # @OUTPUT
  def index
    @venue = Venue.includes(courts: :shared_courts).find(params[:venue_id])
    if params[:start].present? && params[:end].present?
      start_date = TimeSanitizer.input(params[:start])
      end_date = TimeSanitizer.input(params[:end])
    end
    respond_to do |format|
      format.json do
        json = @venue.reservations_shared_courts_json(start_date, end_date)
        render json: json
      end
    end
  end

  def new
    @resv = Reservation.new
    render layout: 'blank'
  end

  def new_cart
    @resv = Reservation.new
    render layout: 'blank'
  end

  # user refund
  def refund
    reservation = Reservation.find(params[:id])

    if reservation.refundable?
      reservation.stripe_refund
      MixpanelTracker.user_cancellation(reservation, current_user)
      reservation.cancel
      message = 'Reservation refunded.'
    else
      message = 'Reservation can not be refunded.'
    end

    redirect_to :back, notice: message
  end

  def show
    @reservation = Reservation.find(params[:id])

    calendar = Icalendar::Calendar.new
    calendar.add_event(@reservation.to_ics)

    respond_to do |format|
      format.html { render layout: 'blank' }
      format.ics { render text: calendar.to_ical }
    end
    # TODO: change this to render partial
  end

  # creation from admin
  def create
    create_reservation_owner
    saved, errors = {}, {}

    sanitized_bookings.each do |key, booking_params|
      r = Reservation.new(booking_params)
      if r.valid? && r.save
        saved[key] = r
        r.track_booking
      else
        errors[key] = r.errors.full_messages
      end
    end

    if errors.any?
      render json: { errors: errors, saved: saved }, status: 422
    else
      render json: { saved: saved }, status: :ok
    end
  end

  def edit
    @resv = Reservation.find(params[:id])
    render layout: 'blank'
  end

  # update from admin
  def update
    @resv = Reservation.find(params[:id])
    @resv.update_by_admin = true
    if @resv.update(reservation_params)
      if params[:pay_reservation]
        @resv.update(payment_type: :paid,
                     amount_paid: @resv.price)
        if params[:pay_with_game_pass].present?
          game_pass = GamePass.find(params[:pay_with_game_pass])
          game_pass.use! if game_pass
        end
      end
      # dragging and resizing on calendar does not send price
      @resv.recalculate_price if reservation_params[:price] === nil
      render nothing: true, status: :ok
    else
      render json: { errors: { '0' => @resv.errors.full_messages } }, status: 422
    end
  end

  def resell_to_user_form
    @reservation = Reservation.find(params[:id])
    render layout: 'blank'
  end

  # sell resell from admin
  # takes params[:user] to find by id or create new user/guest
  def resell_to_user
    @reservation = Reservation.find(params[:id])
    @reservation.update_by_admin = true
    create_reservation_owner

    if @reservation.resell_to_user(@owner)
      @reservation.booking_mail

      render nothing: true, status: :ok
    else
      render json: { errors: { '0' => @reservation.errors.full_messages } }, status: 422
    end
  end

  # cancel [, refund] from admin
  def destroy
    reservation = Reservation.find(params[:id])
    if reservation.is_paid
      reservation.stripe_refund
    end
    if reservation.user.present?
      reservation.cancellation_email
    end

    reservation.cancel
    MixpanelTracker.admin_cancellation(reservation, current_user)

    render nothing: true, status: :ok
  end

  # cancel from user
  def cancel
    reservation = Reservation.find(params[:id])

    if reservation.cancelable?
      MixpanelTracker.user_cancellation(reservation, current_user)
      reservation.cancel
      message = 'Reservation cancelled.'
    else
      message = 'Reservation can not be cancelled.'
    end

    redirect_to :back, notice: message
  end

  def resell
    reservation = Reservation.find(params[:id])
    reservation.update_by_admin = true if current_admin.present?

    if reservation.resold?
      message = 'Reservation already resold.'
    elsif reservation.reselling?
      reservation.update(reselling: false)
      message = 'Reservation resell was withdrawn.'
    else
      reservation.update(reselling: true)
      message = 'Reservation was put on resell.'

      if current_admin.present?
        MixpanelTracker.admin_resell(reservation, current_user)
      else
        MixpanelTracker.user_resell(reservation, current_user)
      end
    end

    respond_to do |format|
      format.html { redirect_to :back, notice: message }
      format.js {
        render text: <<-JS
          resvFormSucc('#{message}')();
        JS
      }
    end
  end

  def show_log
    @reservation = Reservation.unscoped.find(params[:id])

    @court_names = @reservation.logged_courts.each_with_object({}) do |court, hash|
      hash[court.id] = "#{court.court_name} (#{court.sport})"
    end

    render :show_log, layout: 'blank'
  end

  private

  def create_reservation_owner
    if params[:guest]
      @owner = Guest.create(full_name: params[:guest][:full_name])
    else
      @owner = User.find_or_create_by_id(params[:user])

      if @owner.persisted?
        @venue.users << @owner unless @venue.users.include?(@owner)

        unless params[:user][:user_id]
          ConfirmationMailer.confirmation_instructions(
            @owner,
            @owner.confirmation_token,
            {},
            @venue
          ).deliver_now
        end
      end
    end

    @owner
  end

  def reservation_params
    reservation_params = params.require(:reservation)
                               .permit(:start_time, :end_time,
                                       :price, :court_id,
                                       :user_id, :date,
                                       :amount_paid, :note)
    reservation_params[:start_time] = TimeSanitizer.input("#{reservation_params[:date]} #{reservation_params[:start_time]}")
    reservation_params[:end_time] = TimeSanitizer.input("#{reservation_params[:date]} #{reservation_params[:end_time]}")
    reservation_params
  end

  def sanitized_bookings
    params[:reservations].map do |k,r|
      [k, {
            start_time:    TimeSanitizer.input("#{r[:date]} #{r[:start_time]}"),
            end_time:      TimeSanitizer.input("#{r[:date]} #{r[:end_time]}"),
            court_id:      r[:court_id].to_i,
            price:         r[:price].to_f,
            user:          @owner,
            note:          params[:reservation][:note].to_s,
            payment_type: :unpaid,
            booking_type: :admin,
          }]
    end.to_h
  end

  def set_venue
    @venue = Venue.find(params[:venue_id])
  end
end
