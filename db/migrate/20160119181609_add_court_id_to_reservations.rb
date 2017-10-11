class AddCourtIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :court_id, :integer
    remove_column :reservations, :venue_id
  end
end
