class API::GamePassesController < API::BaseController
  before_action :set_venue, only: [:index, :create, :templates, :available, :court_sports]

  def index
    @game_passes = @venue.game_passes.includes(:user).order(:created_at)
  end

  def show
    @game_pass = GamePass.find(params[:id])
  end

  def create
    game_pass = GamePass.new(create_game_pass_params)

    if game_pass.save
      if params[:template_name].present?
        template = game_pass.dup
        template.template_name = params[:template_name]
        template.user_id = nil
        template.save
      end

      render nothing: true, status: :ok
    else
      render nothing: true, status: 422
    end
  end

  def update
    game_pass = GamePass.find(params[:id])

    if game_pass.update(update_game_pass_params)
      if params[:template_name].present?
        template = game_pass.dup
        template.template_name = params[:template_name]
        template.user_id = nil
        template.save
      end

      render nothing: true, status: :ok
    else
      render nothing: true, status: 422
    end
  end

  def destroy
    game_pass = GamePass.find(params[:id])

    if game_pass.destroy
      render nothing: true, status: :ok
    else
      render nothing: true, status: 422
    end
  end

  def available
    court = Court.find(params[:court_id])
    start_time = TimeSanitizer.input(params[:start_time].to_s).in_time_zone
    if params[:end_time].present?
      end_time = TimeSanitizer.input(params[:end_time].to_s).in_time_zone
    elsif params[:duration].present?
      end_time = start_time + params[:duration].to_i.minutes
    end

    game_passes = @venue.game_passes
                        .usable
                        .where(user_id: params[:user_id])
                        .available_for_court(court)
                        .available_for_date(start_time.to_date, end_time.to_date)

    game_passes = game_passes.to_a.select { |gp| gp.usable_at?(start_time, end_time) }
    game_passes = game_passes.map { |gp| { value: gp.id, label: gp.auto_name } }

    render json:  game_passes
  end

  def templates
    @templates = @venue.game_passes.templates
  end

  def court_sports
    render json: @venue.supported_sports_options
  end

  def court_types
    render json:  GamePass.court_types_options
  end

  private

  def set_venue
    @venue = Venue.find(params[:venue_id])
  end

  def game_pass_params
    params.require(:game_pass).permit(
      :name,
      :user_id,
      :court_type,
      :start_date,
      :end_date,
      :price,
      :total_charges,
      :remaining_charges,
      :active,
      court_sports: [],
      time_limitations: [:from, :to, weekdays: []],
    )
  end

  def create_game_pass_params
    game_pass_params.merge(
      active: true,
      venue_id: params[:venue_id],
      remaining_charges: params[:game_pass][:total_charges]
    )
  end

  def update_game_pass_params
    if params[:mark_as_paid].present?
      game_pass_params.merge(is_paid: true)
    else
      game_pass_params
    end
  end
end
