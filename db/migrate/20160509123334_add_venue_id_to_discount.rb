class AddVenueIdToDiscount < ActiveRecord::Migration
  def change
    add_reference :discounts, :venue, index: true, foreign_key: true
  end
end
