class FixVersion < ActiveRecord::Migration
  def change
    remove_column :invoice_components, :price
    add_column :invoice_components, :price, :decimal, precision: 8, scale: 2
  end
end
