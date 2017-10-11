# Handles actions affecting discounts models
class DiscountsController < ApplicationController
  authorize_resource

  def index
    venue = Venue.find(params[:venue_id])
    render json: venue.discounts
  end

  def create
    venue = Venue.find(params[:venue_id])
    discount = venue.discounts.new(discount_params)
    if discount.save
      render partial: 'discounts/show',
             locals: { venue: discount.venue, discount: discount }
    else
      render json: discount.errors.full_messages, status: 422
    end
  end

  def destroy
    discount = Discount.find(params[:id]).destroy
    render json: discount
  end

  def edit
    discount = Discount.find(params[:id])
    render partial: 'edit',
           locals: { venue: discount.venue,
                     discount: discount }
  end

  def update
    discount = Discount.find(params[:id])
    discount.assign_attributes(discount_params)
    if discount.save
      render partial: 'show',
             locals: { venue: discount.venue,
                       discount: discount }
    else
      render json: discount.errors.full_messages, status: 422
    end
  end

  private

  def discount_params
    params.require(:discount).permit(:name, :value, :method, :round)
  end
end
