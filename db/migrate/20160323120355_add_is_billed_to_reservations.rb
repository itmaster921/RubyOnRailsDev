class AddIsBilledToReservations < ActiveRecord::Migration
  def change
    add_column :invoice_components, :is_billed, :boolean, null: false, default: false
  end
end
