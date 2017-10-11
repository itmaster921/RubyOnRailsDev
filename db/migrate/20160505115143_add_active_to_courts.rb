class AddActiveToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :active, :boolean
  end
end
