class AddCourtCounterToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :indoor_count, :integer, default: 0
    add_column :venues, :outdoor_count, :integer, default: 0
  end
end
