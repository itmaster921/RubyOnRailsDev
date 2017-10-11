class AddInactiveToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :inactive, :boolean, default: false
  end
end
