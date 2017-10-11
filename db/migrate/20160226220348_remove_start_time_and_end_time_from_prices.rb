class RemoveStartTimeAndEndTimeFromPrices < ActiveRecord::Migration
  def change
    remove_column :prices, :start_time, :datetime
    remove_column :prices, :end_time, :datetime
  end
end
