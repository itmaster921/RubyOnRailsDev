# Handle venue actions
# TODO: Fix this controller
class VenuesController < ApplicationController
  include Gallery
  include Reservable

  before_action :authenticate_admin!, except: [:show, :available,
                                               :make_reservation, :edit_emails,
                                               :make_unpaid_reservation,
                                               :booking_ahead_limit,
                                               :reports, :booking_sales_report,
                                               :closing_hours]
  before_action :authenticate_user!, only: [:make_reservation,
                                            :make_unpaid_reservation]
  before_action :set_venue, only: [:show, :edit, :update, :view,
                                   :available, :make_reservation,
                                   :make_unpaid_reservation,
                                   :map_users, :courts,
                                   :court_price_at,
                                   :memberships, :reports,
                                   :booking_sales_report,
                                   :cancelled_reservations,
                                   :available_court_indexes]

  def index
    @venues = current_company.venues
    @courts = @venue.courts
    @customers = map_users
  end

  def view
    @venues = current_company.venues
    @courts = @venue.courts
    @photos = @venue.photos
    @resv = @venue.reservations.build
  end

  def courts
    @venues = current_company.venues
    @courts = @venue.courts
    @photos = @venue.photos
  end

  def courts_and_prices
    @venues = current_company.venues
    @venue = Venue.includes({courts: [:shared_courts, :day_offs]}, :prices).find(params[:id])
    @offdays = @venue.all_offdays
    @courts = @venue.courts.sort_by{|c| [c.sport_name, (c.indoor ? 0 : 1), c.index]}
    @photos = @venue.photos
    @prices = @venue.prices.uniq
  end

  def memberships
    @memberships = @venue.memberships.includes(:user)
    #@memberships = @venue.memberships.includes(:user, reservations: :court)
    # for some reason .includes is slow, workaround here
    @reservations = Reservation.reservations_for_memberships(@memberships.map(&:id))
  end

  def map_users
    @users = @venue.map_users
    respond_to do |format|
      format.html {}
      format.json do
        json = []
        @users.each do |u|
          json << {
            name: u[:name] + ' ' + u[:email],
            id: u[:id]
          }
        end
        render json: json
      end
    end
  end

  def available
    @time = TimeSanitizer.input("#{params[:date]}  #{params[:time]}")
                         .beginning_of_hour
    @duration = params[:duration].to_i

    search = Search.new(
      date_time: @time,
      duration: @duration,
      venue: @venue,
      user_id: params['userId'],
      sport_name: params[:sport_name]
    )

    @available = search.venue_result

    respond_to do |type|
      type.html { render layout: false }
    end
  end

  def closing_hours
    render json: Venue.find(params[:venue_id]).closing_hours
  end

  def court_price_at
    start_time = TimeSanitizer.input(params['start_time'])
    end_time = TimeSanitizer.input(params['end_time'])
    court = Court.find(params['court_id'])
    unless params['user_id'].blank?
      discount = User.find(params['user_id'])
                     .discounts
                     .find_by(venue_id: @venue.id)
    end
    price = court.price_at(start_time, end_time, discount)
    render json: { price: price }
  end

  def courts_by_surface(surface)
    venue = Venue.find(params[:venue_id])
    render json: venue.courts_by_surface_json(surface)
  end

  def show
    unless @venue.listed?
      render file: 'public/404.html', status: :unauthorized
      return
    end
    @venues = current_company.venues
    @courts = @venue.courts
    @photos = @venue.photos
    @lowprice = @venue.prices.map(&:price).sort.first.to_i
    @highprice = @venue.prices.map(&:price).sort.reverse.first.to_i
  end

  def new
    @venue = current_company.venues.build
  end

  def create
    @venue = current_company.venues.build(venue_params)
    @venue.parse_business_hours(params[:hours])

    if @venue.save
      if params[:images]
        params[:images].each_with_index do |image, index|
          @venue.photos.create(image: image[1])
        end
      end
      @photos = @venue.photos
      respond_to do |format|
        format.html { redirect_to courts_and_prices_path(@venue), notice: "Saved..." }
        format.js { render nothing: true, status: :ok }
        format.json { render json: { location: courts_and_prices_path(@venue) }}
      end
    else
      respond_to do |format|
        format.html { render :new, status: 406}
        format.json { render nothing: true, status: 406 }
      end
    end
  end

  def edit
    if current_admin.company == current_company
      @gallery_images = gallery_images(@venue)
      @venues = current_company.venues
    else
      redirect_to root_path, notice: 'No permissions.'
    end
  end

  def edit_emails
    @venue = Venue.find(params[:venue_id])
  end

  def update_emails
    @venue = Venue.find(params[:venue_id])
    @venue.update_attributes(venue_params)
    redirect_to :back, notice: 'Emails Updated'
  end

  def update
    @venue.assign_attributes(venue_params)
    @venue.parse_business_hours(params[:hours]) if params[:hours].present?
    if @venue.save
      respond_to do |format|
        format.html { redirect_to edit_venue_path(@venue), notice: 'Updated...' }
        format.js { render nothing: true, status: :ok }
        format.json { render nothing: true, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: @venue.errors.full_messages, status: 422 }
        format.html { render :edit, status: 422, notice: 'Update failed..' }
        format.js { render nothing: true, status: 422 }
      end
    end
  end

  def offdays
    venue = Venue.find(params[:venue_id])
    offdays = venue.offdays_as_json
    render json: offdays
  end

  def court_modal
    court = Court.find(params[:id])
    venue = Venue.find(params[:venue_id])
    render partial: 'manage_court', locals: { venue: venue, court: court }
  end

  def destroy
    @venue = Venue.find(params[:id]).destroy
    redirect_to company_path(@venue.company)
  end

  def booking_ahead_limit
    venue = Venue.find(params[:venue_id])
    booking_limiter = [{
                        start: (Date.today + venue.booking_ahead_limit.days).at_beginning_of_day,
                        end: (Date.today + venue.booking_ahead_limit.days + 10.years).at_end_of_day
                      }]
    render json: booking_limiter
  end

  def active_courts
    venue = Venue.find(params[:venue_id])
    render json: venue.active_courts_json
  end

  def available_court_indexes
    search_params = {
      indoor: params[:indoor] == 'indoor' ? true : false,
      sport_name: Court.sport_names[params[:sport_name].to_s],
      custom_sport_name: params[:custom_sport_name].to_s
    }

    exept_id = Court.find_by_id(params[:exept_court]).try(:id)

    indexes = @venue.available_court_indexes(search_params, exept_id, params[:copies].to_i)

    render json: indexes
  end

  def change_listed
    venue = Venue.find(params[:venue_id])
    if venue.update_attributes(listed: params[:state] == 'true')
      render json: venue, status: :ok
    else
      render json: venue.errors, status: 422
    end
  end

  def manage_discounts
    @venue = Venue.find(params[:venue_id])

    @users =  User.search(params[:search])
                  .where(id: @venue.users)
                  .includes(:discounts)
                  .order(:created_at)
                  .page(params[:page]).per_page(10)
  end

  def reports
  end

  def booking_sales_report
    from = TimeSanitizer.input(TimeSanitizer.output(report_params[:from]).beginning_of_day.to_s)
    to = TimeSanitizer.input(TimeSanitizer.output(report_params[:to]).end_of_day.to_s)
    reservations = @venue.reservations.includes(:court, :user).where(start_time: from..to).order(:start_time)
    report = @venue.generate_xlsx(reservations, from, to, current_admin)
    range = [from, to].map{|t| t.strftime('%d-%m-%Y')}.join('_')
    filename = "Sales_Report_#{range}.xlsx"
    send_data report.to_stream.read, filename: filename
  end

  def cancelled_reservations
    @reservations = @venue.reservations.unscoped
                          .where(inactive: true)
                          .order(updated_at: :desc)
                          .includes(:user, :court)
  end

  private

  def set_venue
    @venue = Venue.find(params[:id])
  end

  def venue_params
    params.require(:venue).permit(:venue_name, :latitude, :longitude, :description,
                                  :parking_info, :transit_info, :website, :phone_number,
                                  :monday_opening_time, :tuesday_opening_time,
                                  :wednesday_opening_time, :thursday_opening_time,
                                  :friday_opening_time, :saturday_opening_time,
                                  :sunday_opening_time, :monday_closing_time,
                                  :tuesday_closing_time, :wednesday_closing_time,
                                  :thursday_closing_time, :friday_closing_time,
                                  :saturday_closing_time, :sunday_closing_time,
                                  :active, :street, :zip, :city, :booking_ahead_limit,
                                  :confirmation_message, :registration_confirmation_message,
                                  :cancellation_time,
                                  custom_colors: Venue::DEFAULT_COLORS.keys)
  end

  def report_params
    params.require(:report).permit(:from, :to)
  end

  def current_company
    if current_admin
      return current_admin.company
    else
      return @venue.company
    end
  end
end
