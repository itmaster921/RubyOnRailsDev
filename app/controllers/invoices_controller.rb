class InvoicesController < ApplicationController
  before_action :set_company
  before_action :set_invoice, only: [:update, :show]

  def index
    @invoices = @company.invoices.includes(:user, :custom_invoice_components, invoice_components: { reservation: :court })
    @mode = params[:mode]
    case @mode
    when 'unpaid'
      @invoices = @invoices.unpaid
    when 'paid'
      @invoices = @invoices.paid
    else
      @mode = 'drafts'
      @invoices = @invoices.drafts
    end

    @outstanding_balances = @company.outstanding_balances
    users_with_balance = @outstanding_balances.map { |id,balance| id if balance != 0.0 }.compact
    @users = User.where(id: users_with_balance)
  end

  def create_drafts
    @users = User.where(id: invoice_drafts_params[:user_ids])
    redirect_to(:back, notice: "Please select some users") and return if @users.empty?
    @invoices = {} # user_id => invoice
    from = TimeSanitizer.input(TimeSanitizer.output(invoice_drafts_params[:start_date]).beginning_of_day.to_s)
    to = TimeSanitizer.input(TimeSanitizer.output(invoice_drafts_params[:end_date].to_date).end_of_day.to_s)
    @users.each do |user|
      reservations = user.reservations.
        where('? <= start_time and end_time <= ?',
              from, to).
        where(is_billed: false).
        where(court_id: @company.court_ids)
      if reservations.any?
        @invoices[user.id] = Invoice.create_for_company_and_reservations(@company, reservations, user)
        #price number_with_precision(@invoice.invoice_components.map(&:price).inject(:+), :precision => 2)
      end
    end
    if @invoices.keys.empty?
      redirect_to :back, notice: "There's nothing to invoice for this period."
    else
      redirect_to company_invoices_path(@company), notice: "#{@invoices.keys.size} invoices were generated successfully. Now review and send them."
    end
  end

  def send_all
    params[:selected_ids].each do |id|
      @company.invoices.find(id).send!
    end
    redirect_to company_invoices_path(@company),
      notice: "#{params[:selected_ids].size} invoices were sent out successfully"
  end

  def mark_paid
    count = Invoice.mark_paid(params[:selected_ids])
    redirect_to company_invoices_path(@company),
      notice:  t('.success', count: count)
  end

  def destroy_all
    params[:selected_ids].each do |id|
      @company.invoices.find(id).destroy
    end
    redirect_to company_invoices_path(@company, mode: 'unpaid'),
      notice: "#{params[:selected_ids].size} invoices were deleted successfully"
  end

  def update
    @invoice.assign_attributes(invoice_params)
    if @invoice.save
      render json: {status: 'updated', invoice: { total: @invoice.total }}
    else
      render json: {error: 'validation error'}
    end
  end

  def show
    @invoice = Invoice.includes(:user, invoice_components: { reservation: :court }).find(params[:id])
    @customer = @invoice.user
  end

  def create_report
    from = TimeSanitizer.input(TimeSanitizer.output(report_params[:from]).beginning_of_day.to_s)
    to = TimeSanitizer.input(TimeSanitizer.output(report_params[:to]).end_of_day.to_s)
    invoices = @company.invoices.includes(:user).where(billing_time: from..to, is_draft: false).order(:created_at)
    report = Invoice.generate_invoice_excel(@company, invoices, current_admin, from, to)
    range = [from, to].map{|t| t.strftime('%d-%m-%Y')}.join('_')
    filename = "Invoice_Report_#{range}.xlsx"
    send_data report.to_stream.read, filename: filename
  end

  protected

  def set_company
    if current_admin.try(:company)
      @company = current_admin.company
    elsif Company.find(params[:company_id])
      @company = Company.find(params[:company_id])
    end
  end

  def set_invoice
    @invoice = @company.invoices.find(params[:id])
  end

  def invoice_params
    params.require('invoice').permit(:total)
  end

  def invoice_drafts_params
    params.permit(:start_date, :end_date, :user_ids => [])
  end

  def report_params
    params.require(:report).permit(:from, :to)
  end
end
