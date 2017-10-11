class AddStartTimeAndEndTimeToInvoiceComponents < ActiveRecord::Migration
  def change
    add_column :invoice_components, :start_time, :datetime
    add_column :invoice_components, :end_time, :datetime
  end
end
