class RemoveRedundantColumnsFromVenue < ActiveRecord::Migration
  def change
    remove_column :venues, :saturday_opening_time
    remove_column :venues, :sunday_opening_time
    remove_column :venues, :monday_opening_time
    remove_column :venues, :tuesday_opening_time
    remove_column :venues, :wednesday_opening_time
    remove_column :venues, :thursday_opening_time
    remove_column :venues, :friday_opening_time
    remove_column :venues, :saturday_closing_time
    remove_column :venues, :sunday_closing_time
    remove_column :venues, :monday_closing_time
    remove_column :venues, :tuesday_closing_time
    remove_column :venues, :wednesday_closing_time
    remove_column :venues, :thursday_closing_time
    remove_column :venues, :friday_closing_time
  end
end
