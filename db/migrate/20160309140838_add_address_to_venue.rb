class AddAddressToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :street, :string
    add_column :venues, :city, :string
    add_column :venues, :zip, :string
  end
end
