class AddCancelTimeToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :cancellation_time, :integer, default: 24, null: false
  end
end
