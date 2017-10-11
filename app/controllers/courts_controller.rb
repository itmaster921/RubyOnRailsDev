class CourtsController < ApplicationController
  before_action :set_court, only: [:show, :edit, :update]
  before_action :authenticate_admin!, except: [:show]

  COLORS = %w(
    'blue'
    'green'
    'yellow'
    'red'
  ).freeze

  def index
    if params[:sport].present? && params[:surface].present?
      if params[:surface] == 'all'
        @courts = current_venue.courts.select do |c|
          c.sport_name == params[:sport] && c.custom_sport_name == nil ||
            c.custom_sport_name == params[:sport]
        end
      else
        @courts = current_venue.courts.select do |c|
          (c.sport_name == params[:sport] && c.custom_sport_name == nil ||
          c.custom_sport_name == params[:sport]) &&
            c.surface == params[:surface]
        end
      end
    else
    @courts = current_venue.courts
    end
    @courts = @courts.sort_by{|c| [c.sport_name, (c.indoor ? 0 : 1), c.index]}

    respond_to do |format|
      format.html {}
      format.json do
        json = []
        @courts.each_with_index do |c, i|
          json << {
            id: c.id,
            title: c.court_name,
            title_with_sport: "#{c.court_name} (#{c.sport})",
            eventColor: COLORS[i % COLORS.size]
          }
        end
        render json: json
      end
    end
  end

  def new
    @venue = Venue.includes(courts: :shared_courts).find(params[:venue_id])
    court = @venue.courts.new
    court_form_builder = ActionView::Helpers::FormBuilder.new(:court, court, view_context, {})
    render partial: 'form', locals: {court: court_form_builder}
  end

  def show
    @venues = current_company.venues
    @venue = current_venue
    @new_price = @court.prices.build
  end

  def create
    copies = params[:copies].to_i
    court_attrs = court_params
    court_attrs['shared_courts'] = Court.where(id: court_attrs['shared_courts'])
    @court = current_venue.courts.build(court_attrs)
    if @court.valid?
      copies.times do
        current_venue.courts.create(court_attrs)
      end
      render partial: 'courts/index',
             locals: { venue: current_venue, courts: current_venue_shared_courts.courts },
             status: :ok
    else
      render json: @court, status: 422
    end
  end

  def edit
    @venue = @court.venue
    render layout: 'blank'
  end

  def update
    court_attrs = court_params
    if params[:share_court]
      court_attrs['shared_courts'] = Court.where(id: court_attrs['shared_courts'])
    else
      CourtConnector.remove_connectors_for_court(@court.id)
      @court.reload
    end
    if @court.update(court_attrs)
      render partial: 'courts/court',
             locals: { venue: @court.venue, court: @court },
             status: :ok
    else
      render json: @court, status: 422
    end
  end

  def destroy
    court = Court.find(params[:id]).destroy
    render json: court, status: :ok
  end

  private

  def set_court
    @court = Court.includes(:shared_courts).find(params[:id])
  end

  def court_params
    court_params = params.require(:court)
                         .permit(:sport_name, :court_description,
                                 :active, :duration_policy,
                                 :start_time_policy, :indoor,
                                 :payment_skippable, :surface,
                                 :custom_sport_name, :index,
                                 :shared_courts => [])
    court_params[:indoor] = court_params[:indoor] == 'indoor'
    court_params
  end

  def current_company
    current_admin.company
  end

  def current_venue
    Venue.includes(:courts).find(params[:venue_id])
  end

  def current_venue_shared_courts
    Venue.includes({courts: [:shared_courts]}).find(params[:venue_id])
  end
end
