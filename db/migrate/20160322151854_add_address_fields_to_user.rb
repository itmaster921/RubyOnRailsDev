class AddAddressFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :street_address, :string
    add_column :users, :zipcode, :string
    add_column :users, :city, :string
    add_column :users, :outstanding_balance, :float
  end
end
