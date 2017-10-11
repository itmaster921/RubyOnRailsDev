class AddResellingToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :initial_owner_id, :integer
    add_column :reservations, :reselling, :boolean, default: false
  end
end
