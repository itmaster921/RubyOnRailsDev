class UsersController < ApplicationController
  def show
    @user = current_user
    @mode = params[:mode]

    @reservations = case @mode
    when 'future'
      current_user.future_reservations.include_venues.order(start_time: :asc)
    when 'past'
      current_user.past_reservations.include_venues.order(start_time: :desc)
    else
      @mode = 'future'
      current_user.future_reservations.include_venues.order(start_time: :asc)
    end
    render :layout => "newlayout"
  end

  def recurring_reservations
    @user = current_user
    @mode = params[:mode]
    @recurring = true

    @reservations = case @mode
    when 'future'
      current_user.future_memberships.include_venues.order(start_time: :asc)
    when 'past'
      current_user.past_memberships.include_venues.order(start_time: :desc)
    when 'reselling'
      current_user.reselling_memberships.include_venues.order(start_time: :desc)
    when 'resold'
      current_user.resold_memberships.include_venues.order(start_time: :desc)
    else
      @mode = 'future'
      current_user.future_memberships.include_venues.order(start_time: :asc)
    end
    render 'show', :layout => "newlayout"
  end

  def invoices
    @user = current_user
    @reservations = current_user.reservations.where('start_time > ?', DateTime.now).order(start_time: :asc)
    @invoices = current_user.invoices
    @mode = params[:mode]
    case @mode
    when 'unpaid'
      @invoices = @invoices.unpaid
    when 'paid'
      @invoices = @invoices.paid
    else
      @mode = 'unpaid'
      @invoices = @invoices.unpaid
    end
  end

  def assign_discount
    user = User.find(params[:user_id])
    if params[:discount_create]
      user.assign_discount(Discount.find(params[:discount_id]))
    else
      user.discounts.delete(params[:discount_id])
    end
    render nothing: true
  end

  def card_reminder
    user = User.find(params[:user_id])
    venue = Venue.find(params[:venue_id])
    UserMailer.membership_card_reminder(user, venue).deliver_now
    redirect_to memberships_path(venue)
  end
end
