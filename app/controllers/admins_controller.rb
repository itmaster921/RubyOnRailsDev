# Handle admin actions
class AdminsController < ApplicationController
  before_action :authenticate_admin!

  authorize_resource

  def index
    @company = Company.find(params[:company_id])
    @admins = @company.admins
  end

  def create
    company = Company.find(params[:company_id])
    admin = company.admins.new(admin_params)
    if admin.save
      render partial: 'show', locals: { company: company, admin: admin }
    else
      render json: admin.errors.full_messages, status: 422
    end
  end

  def edit
    company = Company.find(params[:company_id])
    admin = Admin.find(params[:id])
    render partial: 'edit', locals: { company: company, admin: admin }
  end

  def update
    admin = Admin.find(params[:id])
    if admin.update(admin_params)
      admin.save_passport(params[:passport]) unless params[:passport].nil?
      render partial: 'show', locals: { admin: admin, company: admin.company }
    else
      render json: admin.errors.full_messages, status: 422
    end
  end

  def destroy
    admin = Admin.find(params[:id])
    if admin.god?
      render json: ['Company must have at least one super admin'], status: 422
    else
      admin.destroy
      render json: admin
    end
  end

  private

  def admin_params
    params.require(:admin).permit(:first_name, :last_name,
                                  :email, :admin_birth_day,
                                  :admin_birth_month, :admin_birth_year,
                                  :admin_ssn, :level)
  end
end
