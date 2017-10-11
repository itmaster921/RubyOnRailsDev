class RenamePercentageColumnDiscount < ActiveRecord::Migration
  def change
    rename_column :discounts, :precentage, :percentage
  end
end
