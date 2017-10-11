class AddTypeToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :method, :integer
    add_column :discounts, :round, :boolean
  end
end
