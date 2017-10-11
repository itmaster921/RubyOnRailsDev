class ChangeDayOffDateToStartDate < ActiveRecord::Migration
  def change
    rename_column :day_offs, :date, :start_date
  end
end
