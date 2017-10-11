class RemoveIndoorOutdoorCountFromVenue < ActiveRecord::Migration
  def change
    remove_column :venues, :indoor_count
    remove_column :venues, :outdoor_count
  end
end
