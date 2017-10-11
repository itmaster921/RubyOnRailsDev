class ChangeCourtSportType < ActiveRecord::Migration
  def change
    remove_column :courts, :sport_name, :string
    add_column :courts, :sport_name, :integer
  end
end
