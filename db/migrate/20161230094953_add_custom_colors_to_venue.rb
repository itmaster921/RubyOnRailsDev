class AddCustomColorsToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :custom_colors, :text
  end
end
