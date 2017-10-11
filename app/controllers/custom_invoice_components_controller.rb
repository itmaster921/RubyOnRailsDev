class CustomInvoiceComponentsController < ApplicationController
  before_action :set_invoice
  before_action :set_custom_invoice_component, only: [:destroy]

  def create
    @custom_invoice_component = @invoice.custom_invoice_components
                                       .build(custom_invoice_component_params)

    @invoice.calculate_total! if @custom_invoice_component.save

    respond_to do |format|
      if @custom_invoice_component.errors.any?
        errors = @custom_invoice_component.errors.full_messages
        format.json { render json: errors, status: 422 }
        format.html { redirect_to :back, error: errors.join('; '), status: 422 }
      else
        format.json { render 'invoices/custom_invoice_component', status: :ok }
        format.html { redirect_to :back, notice: I18n.t('invoices.drafts_table.custom_component_created'), status: :ok }
      end
    end
  end

  def destroy
    @custom_invoice_component.destroy
    respond_to do |format|
      format.js {
        invoice = @custom_invoice_component.invoice
        invoice.calculate_total!
        render text: <<-JS
          $('#custom_invoice_component_#{@custom_invoice_component.id}').remove();
          $('#invoice_#{invoice.id}_total').text(#{invoice.total});
        JS
      }
    end
  end

  protected

  def custom_invoice_component_params
    params.require(:custom_invoice_component)
          .permit(:price, :name, :vat_decimal)
  end

  def set_custom_invoice_component
    @custom_invoice_component = CustomInvoiceComponent.where(invoice: @invoice).find(params[:id])
  end

  def set_invoice
    @invoice = Invoice.find(params[:invoice_id])
  end
end
