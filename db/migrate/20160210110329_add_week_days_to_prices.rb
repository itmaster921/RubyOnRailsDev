class AddWeekDaysToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :monday, :boolean
    add_column :prices, :tuesday, :boolean
    add_column :prices, :wednesday, :boolean
    add_column :prices, :thursday, :boolean
    add_column :prices, :friday, :boolean
    add_column :prices, :saturday, :boolean
    add_column :prices, :sunday, :boolean
  end
end
