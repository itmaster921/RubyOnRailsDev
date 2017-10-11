class ChangePercentageToValue < ActiveRecord::Migration
  def change
    rename_column :discounts, :percentage, :value
  end
end
