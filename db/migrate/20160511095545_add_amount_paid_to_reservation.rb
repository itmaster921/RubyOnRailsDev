class AddAmountPaidToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :amount_paid, :integer
  end
end
