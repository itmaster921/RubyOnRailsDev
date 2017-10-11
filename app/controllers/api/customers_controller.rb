class API::CustomersController < API::BaseController
  before_action :authenticate_admin!
  before_action :set_user, except: [:index, :create]
  before_action :reject_confirmed_user, only: [:update, :destroy]
  before_action :set_company
  before_action :reject_shared_user, only: [:destroy]

  # users and data for current company
  def index
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10

    @customers =  User.search(params[:search]).
                   where(id: @company.users).
                   order(:created_at).
                   page(params[:page]).
                   per_page(per_page)


    @outstanding_balances = @company.outstanding_balances
    @reservations = @company.user_reservations(@customers).group_by(&:user_id)
  end

  def show
    # outstanding balance and reservations for current company
    @outstanding_balance = @company.user_outstanding_balance(@customer)
    @lifetime_balance = @company.user_lifetime_balance(@customer)
    @reservations = @company.user_reservations(@customer)
  end

  def create
    @customer = User.new(user_params)

    if @customer.save
      @company.venues.first.add_customer(@customer)

      render 'show', status: :ok
    else
      render json: { errors: @customer.errors.full_messages }, status: 422
    end
  end

  def update
    @customer.skip_reconfirmation!
    if @customer.update(user_params)
      head :ok
    else
      render json: { errors: @customer.errors.full_messages }, status: 422
    end
  end

  def destroy
    if @customer.destroy
      head :ok
    else
      render json: { errors: [I18n.t('api.customers.cant_delete')] }, status: 422
    end
  end

  private

  def set_user
    @customer = User.find_by_id(params[:id])

    if @customer.blank?
      render json: { errors: [I18n.t('api.customers.user_not_found')] }, status: 404
    end
  end

  def reject_confirmed_user
    if @customer.confirmed? || @customer.encrypted_password.present? || @customer.uid.present?
      render json: { errors: [I18n.t('api.customers.already_confirmed')] }, status: 422
    end
  end

  def set_company
    @company = current_admin.company

    unless @company.venues.count > 0
      render json: { errors: [I18n.t('api.customers.no_venue')] }, status: 422
    end
  end

  # can't delete if user has relation with other company
  def reject_shared_user
    unless @customer.companies.count == 1 && @customer.companies.include?(@company)
      render json: { errors: [I18n.t('api.customers.shared_user')] }, status: 422
    end
  end

  def user_params
    params.require(:customer).permit(
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :city,
      :street_address,
      :zipcode,
    )
  end
end
