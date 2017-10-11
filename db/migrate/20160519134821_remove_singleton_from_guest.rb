class RemoveSingletonFromGuest < ActiveRecord::Migration
  def change
    remove_column :guests, :singleton, :integer
  end
end
