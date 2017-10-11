class AddMustPayToCourt < ActiveRecord::Migration
  def change
    add_column :courts, :payment_skippable, :boolean
  end
end
