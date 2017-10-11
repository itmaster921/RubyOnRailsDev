module API
  # Base controller for all api controllers
  class BaseController < ApplicationController
    before_action :set_default_response_format
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token

    # Custom classes for authentication
    class NotAuthenticatedError < StandardError; end
    class AuthenticationTimeoutError < StandardError; end

    attr_reader :current_user

    rescue_from AuthenticationTimeoutError, with: :authentication_timeout
    rescue_from NotAuthenticatedError, with: :user_not_authenticated

    def locale
      I18n.locale = session[:locale] = locale_params
      @current_user.update(locale: locale_params) unless @current_user.nil?
      render nothing: true
    end

    protected

    def set_default_response_format
      request.format = :json
    end

    # This method gets the current user based on the user_id included
    # in the Authorization header (json web token).
    #
    # Call this from child controllers in a before_action or from
    # within the action method itself
    def authenticate_request!
      fail NotAuthenticatedError unless user_id_included_in_auth_token?
      @current_user = User.find(decoded_auth_token[:user_id] || decoded_auth_token[:id])
      fail NotAuthenticated if @current_user.blank?
    rescue JWT::ExpiredSignature, JWT::ImmatureSignature
      raise AuthenticationTimeoutError
    rescue JWT::VerificationError, JWT::DecodeError, ActiveRecord::RecordNotFound
      raise NotAuthenticatedError
    end

    def json_params_for(required: nil, permitted: [])
      json_params = ActionController::Parameters.new( JSON.parse(request.body.read) )

      if required
        permitted_params = json_params.require(required)
      else
        permitted_params = json_params
      end

      permitted_params.permit(*permitted)
    rescue JSON::ParserError
      {}
    end

    private

    def locale_params
      params.require(:locale)
    end

    def user_id_included_in_auth_token?
      http_auth_token && decoded_auth_token && decoded_auth_token[:id]
    end

    # Decode the authorization header token and return the payload
    def decoded_auth_token
      @decoded_auth_token ||= AuthToken.decode(http_auth_token)
    end

    # Raw Authorization Header token (json web token format)
    # JWT's are stored in the Authorization header using this format:
    # Bearer somerandomstring.encoded-payload.anotherrandomstring
    def http_auth_token
      @http_auth_token ||= if request.headers['Authorization'].present?
                             request.headers['Authorization'].split(' ').last
                           end
    end

    def authentication_timeout
      render json: { errors: [I18n.t('api.authentication.timeout')] }, status: 419
    end

    def user_not_authenticated
      render json: { errors: [I18n.t('api.authentication.unauthorized')] }, status: :unauthorized
    end

  end
end
