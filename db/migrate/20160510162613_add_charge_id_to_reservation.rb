class AddChargeIdToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :charge_id, :string
  end
end
