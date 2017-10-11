module API
  # handles user credit cards actions
  class CardsController < API::BaseController
    before_action :authenticate_request!
    def index
    end

    def create
      if @current_user.has_stripe?
        @current_user.add_card(params[:token])
      else
        @current_user.add_stripe_id(params[:token])
      end
      #MixpanelTracker.credit_card(@current_user)
      #todo CHECK IT WAS SUCCESFUL
      render template: "api/cards/index.json.jbuilder"
    end
  end
end
