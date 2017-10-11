module API
  # Handles user side recurring reservations
  class SubscriptionsController < API::BaseController
    before_action :authenticate_request!

    def index
      @subscriptions = case params[:scope]
                      when 'past'
                        @current_user.past_memberships
                      when 'reselling'
                        @current_user.reselling_memberships
                      when 'resold'
                        @current_user.resold_memberships
                      else
                        params[:scope] = 'future'
                        @current_user.future_memberships
                      end
    end
  end
end
