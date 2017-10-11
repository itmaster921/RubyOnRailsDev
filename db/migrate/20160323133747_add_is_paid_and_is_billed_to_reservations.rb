class AddIsPaidAndIsBilledToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :is_paid, :boolean, null: false, default: false
    add_column :reservations, :is_billed, :boolean, null: false, default: false
  end
end
