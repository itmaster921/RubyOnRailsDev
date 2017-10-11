class ChangePriceDayToInteger < ActiveRecord::Migration
  def change
    remove_column :prices, :day
    add_column :prices, :day_of_week, :integer
  end
end
