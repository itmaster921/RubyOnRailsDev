class AddEndDateToDayOff < ActiveRecord::Migration
  def change
    add_column :day_offs, :end_date, :date
  end
end
