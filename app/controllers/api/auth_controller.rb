class API::AuthController < API::BaseController

  before_action :validate_confirmed_user, only: [:authenticate]

  def authenticate
    user = User.authenticate(params[:email], params[:password])

    if user
      render json: authentication_payload(user)
    else
      render json: { errors: ['Invalid username or password'] }, status: :unauthorized
    end
  end

  private

  def authentication_payload(user)
    return nil unless user && user.id
    {
      auth_token: AuthToken.encode({
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        provider: user.provider,
        uid: user.uid,
        image: user.image,
        phone_number: user.phone_number,
        stripe_id: user.stripe_id,
        street_address: user.street_address,
        zipcode: user.zipcode,
        city: user.city
      })
    }
  end

  def validate_confirmed_user
    user = User.find_by_email(params[:email])
    if user.present? && user.encrypted_password.blank? && user.unconfirmed?
      render json: { error: 'unconfirmed_account', message: I18n.t('api.users.not_confirmed') }, status: 422
    end
  end

end
