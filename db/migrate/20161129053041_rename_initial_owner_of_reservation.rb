class RenameInitialOwnerOfReservation < ActiveRecord::Migration
  def change
    rename_column :reservations, :initial_owner_id, :initial_membership_id
  end
end
