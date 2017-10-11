class AddBookingAheadLimitToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :booking_ahead_limit, :integer
  end
end
