class CompaniesController < ApplicationController
  before_action :set_company, except: [:new, :create]
  before_action :authenticate_admin!

  authorize_resource

  def index
  end

  def show
    @resv_data = @company.charges_data('month') if @company.has_stripe?
    @venues = @company.venues
  end

  def customers
  end

  def invoices
  end

  def new
    @company = current_admin.build_company
    render layout: 'newlayout'
  end

  def reports
  end

  def create_report
    @transfers = current_company.transfers(params['report']['start_date'],
                                           params['report']['end_date'])
    render :report
  end

  def report
    @transfers = current_company.transfers(params['start'], params['end'])
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      current_company = @company
      current_admin.update_attribute :company_id, @company.id
      connector = StripeManaged.new(current_company)
      account = connector.create_account!(current_company,
                                          current_admin,
                                          params[:tos] == 'on',
                                          request.remote_ip)
      if account
        flash[:notice] = "Managed Stripe account created! \
                          <a target='_blank' rel='platform-account' \
                          href='https://dashboard.stripe.com/test/
                          applications/users/#{account.id}'>View \
                          in dashboard &raquo;</a>"
      else
        flash[:error] = 'Unable to create Stripe account!'
      end
      redirect_to @company, notice: 'Saved...'
    else
      render :new, layout: 'empty'
    end
  end

  def edit
    @venues = @company.venues
  end

  def update
    if @company.update(company_params)
      redirect_to @company, notice: 'Updated...'
    else
      render :edit
    end
  end

  # post
  def import_customers
    @venue = Venue.find(params[:venue_id])

    importer = CSVImportUsers.new(params[:csv_file], @venue)
    @report = importer.run.report_message
    @failed_customers = importer.invalid_rows

    respond_to do |format|
      format.js
      format.html { redirect_to :back, notice: @report }
    end
  end

  def customers_csv_template
    send_data CSVImportUsers.csv_template, filename: "customers_csv_template.csv"
  end

  private

  def set_company
    @company = current_admin.company
  end

  def company_params
    params.require(:company)
          .permit(:company_legal_name, :company_country,
                  :company_business_type, :company_tax_id,
                  :company_street_address, :company_zip,
                  :company_city, :company_website,
                  :company_iban, :company_phone,
                  :active)
  end

  def current_company
    @company
  end
end
