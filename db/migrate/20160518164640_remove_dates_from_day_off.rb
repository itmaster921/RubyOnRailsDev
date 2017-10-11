class RemoveDatesFromDayOff < ActiveRecord::Migration
  def change
    remove_column :day_offs, :start_date, :date
    remove_column :day_offs, :end_date, :date
    remove_column :day_offs, :start_time
    remove_column :day_offs, :end_time
    add_column :day_offs, :start_time, :datetime
    add_column :day_offs, :end_time, :datetime
  end
end
