class AddInvoiceToInvoiceComponents < ActiveRecord::Migration
  def change
    add_reference :invoice_components, :invoice, index: true, foreign_key: true
  end
end
