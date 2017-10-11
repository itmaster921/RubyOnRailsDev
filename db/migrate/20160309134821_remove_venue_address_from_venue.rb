class RemoveVenueAddressFromVenue < ActiveRecord::Migration
  def change
    remove_column :venues, :venue_address, :string
  end
end
