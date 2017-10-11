class AddBillingTimeToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :billing_time, :datetime
  end
end
