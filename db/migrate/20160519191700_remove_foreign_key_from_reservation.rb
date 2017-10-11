class RemoveForeignKeyFromReservation < ActiveRecord::Migration
  def change
    remove_foreign_key :reservations, :users
  end
end
