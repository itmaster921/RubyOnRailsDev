class AddTypesToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :payment_type, :integer
    add_column :reservations, :booking_type, :integer
  end
end
