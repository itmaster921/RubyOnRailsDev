class AddFieldsToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :venue_address, :string
  end
end
