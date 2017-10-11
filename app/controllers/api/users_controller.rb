class API::UsersController < API::BaseController

  before_action :validate_confirmed_user, only: [:create]
  before_action :authenticate_request!, only: [:update]

  def create
    user = User.new(user_params)
    if user.save
      render json: { auth_token: AuthToken.encode(JSON.parse(user.to_json)) }
    else
      render json: { errors: user.errors.full_messages }, status: 422
    end
  end
  
  def email_check
    if params[:email].blank?
      render json: { message: I18n.t('api.users.email_check.email_required') }, status: 422
    elsif User.find_by_email(params[:email])
      render json: { message: I18n.t('api.users.email_check.success') }, status: 200
    else
      # Is rendered for both invalid Email Parameter and when no User is found
      render json: { message: I18n.t('api.users.email_check.error') }, status: 422
    end
  end

  def confirm_account
    if user_confirmation_params[:email].blank?
      render json: { message: I18n.t('api.users.confirm_account.email_required') }, status: 422
    elsif User.send_confirmation_instructions(user_confirmation_params)
      render json: { message: I18n.t('api.users.confirm_account.success') }, status: 200
    else
      render json: { message: I18n.t('api.users.confirm_account.error') }, status: 422
    end
  end

  def update
    user_params.delete(:email)

    if user_params[:password].present? && user_params[:current_password].blank? || user_params[:password].blank? && user_params[:current_password].present?
      render json: { message: I18n.t('api.users.errors.passwords_required') }, status: 422
    elsif user_params[:current_password] && user_params[:password] && @current_user.update_with_password(user_params)
      render json: { message: I18n.t('api.users.password_updated') }, status: 200
    elsif user_params[:password].blank? && user_params[:current_password].blank? && @current_user.update_without_password(user_params)
      render json: { message: I18n.t('api.users.profile_updated') }, status: 200
    else
      render json: { message: @current_user.errors.full_messages }, status: 422
    end
  end

  def reset_password
    user = User.send_reset_password_instructions(email: params[:email])

    if user.valid?
      render json: { message: I18n.t('api.users.reset_password_email') }, status: 200
    else
      render json: { message: user.errors.full_messages.join(', ') }, status: 404
    end
  end

  def game_pass_check
    user     = User.find(params[:user_id])
    venue    = Venue.find(params[:venue_id])
    @check   = user.has_game_pass?(venue)
    @charges = user.game_passes.where(venue_id:venue.id).first.try(:remaining_charges)
  end

  private

  def validate_confirmed_user
    user = User.find_by_email(params[:email])
    if user.present? && user.encrypted_password.blank? && user.unconfirmed?
      render json: { error: 'unconfirmed_account', message: I18n.t('api.users.not_confirmed') }, status: 422
    elsif user.present? && user.encrypted_password.present? && user.unconfirmed?
      render json: { error: 'already_exists', message: I18n.t('api.users.already_exists') }, status: 422
    end
  end

  def user_params
    json_params_for(
      required: :user,
      permitted: [:city, :email, :first_name, :image, :last_name, :password, :password_confirmation, :phone_number, :provider, :street_address, :stripe_id, :uid, :zipcode, :current_password]
    )
  end

  def user_confirmation_params
    json_params_for(required: :user, permitted: [:email])
  end

end
