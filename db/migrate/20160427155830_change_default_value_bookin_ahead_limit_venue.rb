class ChangeDefaultValueBookinAheadLimitVenue < ActiveRecord::Migration
  def change
    change_column :venues, :booking_ahead_limit, :integer, default: 365
  end
end
