class AddIsPaidToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :is_paid, :boolean, null: false, default: false, index: true
  end
end
