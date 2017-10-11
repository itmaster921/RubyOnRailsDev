class AddReferenceNumberToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :reference_number, :string
  end
end
