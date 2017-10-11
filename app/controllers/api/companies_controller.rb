class API::CompaniesController < ApplicationController

  def send_support_email
    SupportMailer.support_email(params[:title], params[:content], current_admin.email, current_admin.company.company_legal_name).deliver!
    render nothing: true, status: :ok
  end

end
