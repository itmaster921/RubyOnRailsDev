class AddNotesToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :note, :text
  end
end
