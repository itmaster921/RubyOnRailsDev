class AddStartMinuteOfADayAndEndMinuteOfADayToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :start_minute_of_a_day, :integer, index: true
    add_column :prices, :end_minute_of_a_day, :integer, index: true
  end
end
