class AddRefundedBooleanToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :refunded, :boolean, default: false
  end
end
