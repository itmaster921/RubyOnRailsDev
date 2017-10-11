class AddBusinessHoursToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :business_hours, :text
  end
end
