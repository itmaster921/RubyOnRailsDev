class ChangeTimes < ActiveRecord::Migration
  def change
    remove_column :reservations, :start_time
    remove_column :reservations, :end_time

    add_column :reservations, :start_time, :datetime
    add_column :reservations, :end_time, :datetime
  end
end
