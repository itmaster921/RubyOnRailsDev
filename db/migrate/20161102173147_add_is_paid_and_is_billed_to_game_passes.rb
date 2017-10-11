class AddIsPaidAndIsBilledToGamePasses < ActiveRecord::Migration
  def change
    add_column :game_passes, :is_paid, :boolean, default: false
    add_column :game_passes, :is_billed, :boolean, default: false
  end
end
