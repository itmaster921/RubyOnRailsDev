# Handles price actions
class PricesController < ApplicationController
  before_action :set_venue

  def show
    @price = Price.find(params[:id])
    @venue = Venue.find(params[:venue_id])
  end

  def create
    @price = Price.new(price_params)
    if @price.save
      conflicts = []
      court_conflicts = {}

      courts.each do |c|
        div = Divider.new(price: @price, court: c)
        unless div.save
          conflicts << div.conflict_prices
          div.conflict_prices.each do |p|
            court_conflicts[p.id] ||= []
            court_conflicts[p.id] << c.id
          end
        end
      end

      if conflicts.any?
        @price.destroy
        @conflicts = conflicts.flatten.uniq
        @courts = courts
        @court_conflicts = court_conflicts

        render partial: 'venues/prices_modal', locals: {conflicts: @conflicts}, status: 422
      else
        render partial: 'prices/price', locals: { venue: @venue, price: @price }, status: :ok
      end
    else
      render json: @price, status: 422
    end
  end

  def merge_conflicts
    @price = Price.find(params[:id])
    params[:conflicts].each_pair do |price_id, court_ids|
      price = Price.find(price_id)
      courts = court_ids.map { |id| Court.find(id) }
      price.merge_price!(@price, *courts)
    end

    redirect_to :back, notice: 'All the conflicts were resolved'
  end

  def update
    @price = Price.find(params[:id])
    @errors, @conflicts = @price.update_or_find_conflicts(price_params,
                                                          params[:court_ids])
    if @conflicts then render partial: 'venues/prices_modal',
                              locals: { conflicts: @conflicts }, status: 422
    elsif !@errors then render partial: 'prices/price',
                               locals: { venue: @venue, price: @price },
                               status: :ok
    else
      render json: @errors, status: 406
    end
  end

  def destroy
    @price = Price.find(params[:id])
    @price.destroy!
    render json: @price, status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_venue
    @venue = Venue.find(params[:venue_id])
  end

  def price_params
    permittable = [:price, :start_time, :end_time] + Price::WEEKDAYS
    params.require(:price).permit(*permittable)
  end

  def courts
    Court.where(id: params[:court_ids], venue: @venue)
  end
end
