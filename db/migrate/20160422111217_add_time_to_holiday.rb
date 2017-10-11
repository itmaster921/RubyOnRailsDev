class AddTimeToHoliday < ActiveRecord::Migration
  def change
    add_column :day_offs, :start_time, :time
    add_column :day_offs, :end_time, :time
  end
end
