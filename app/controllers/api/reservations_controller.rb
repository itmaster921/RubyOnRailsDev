module API
  # Handles user side reservations
  class ReservationsController < API::BaseController
    before_action :authenticate_request!

    def create
      puts "current_user: #{@current_user}"
      puts "params: #{params}"
      puts "booking params: #{params[:bookings]}"
      sanitizer = ReservationSanitizer.new(@current_user, params)
      reservations = sanitizer.create_reservations
      if reservations
        render nothing: true, status: :ok
      else
        render nothing: true, status: 422
      end
    end

    # without recurring
    def index
      @reservations_past = @current_user.past_reservations.sort_by(&:start_time).reverse
      @reservations_future = @current_user.future_reservations.sort_by(&:start_time)
      @subscriptions_past = @current_user.past_memberships.sort_by(&:start_time).reverse
      @subscriptions_reselling = @current_user.reselling_memberships.sort_by(&:start_time)
      @subscriptions_resold = @current_user.resold_memberships.sort_by(&:start_time)
      @subscriptions_future = @current_user.future_memberships.sort_by(&:start_time)
    end

    def destroy
      r = Reservation.find(params[:reservation_id])
      if r.cancelable?
        MixpanelTracker.user_cancellation(r, current_user)
        r.cancel
        @reservations = @current_user.future_reservations
        render 'index'
      else
        render json: { error: 'Reservation can no longer be cancelled' }
      end
    end
  end
end
