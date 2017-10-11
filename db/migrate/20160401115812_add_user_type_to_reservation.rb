class AddUserTypeToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :user_type, :string
  end
end
