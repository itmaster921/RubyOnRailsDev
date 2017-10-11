class DashboardController < ApplicationController
  before_action :check_stripe

  def revenue
    trans_hist = @company.trans_hist(params[:grouping])
    data = DataSeries.make_trans_series(trans_hist, params[:grouping])
    render json: data, status: :ok
  end

  def resv
    company = Company.find(params[:company_id])
    resv_hist = company.charges(params[:grouping])
    data = DataSeries.make_resv_series(resv_hist, params[:grouping])
    render json: data, status: :ok
  end

  private

  def check_stripe
    @company = Company.find(params[:company_id])
    if not @company.has_stripe?
      render nothing: true, status: 406
    end
  end

end
