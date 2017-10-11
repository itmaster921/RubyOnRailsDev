class AddCustomSportNameToCourt < ActiveRecord::Migration
  def change
    add_column :courts, :custom_sport_name, :string
  end
end
