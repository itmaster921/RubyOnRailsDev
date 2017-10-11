class InvoiceComponentsController < ApplicationController
  before_action :set_invoice
  before_action :set_invoice_component, only: [:destroy]

  def destroy
    @invoice_component.destroy
    respond_to do |format|
      format.js {
        invoice = @invoice_component.invoice
        invoice.calculate_total!
        render text: <<-JS
          $('#invoice_component_#{@invoice_component.id}').detach();
          $('#invoice_#{invoice.id}_total').text(#{invoice.total});
        JS
      }
    end
  end

  protected

  def set_invoice_component
    @invoice_component = InvoiceComponent.where(invoice: @invoice).find(params[:id])
  end

  def set_invoice
    @invoice = Invoice.find(params[:invoice_id])
  end
end
