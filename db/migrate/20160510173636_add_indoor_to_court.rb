class AddIndoorToCourt < ActiveRecord::Migration
  def change
    add_column :courts, :indoor, :boolean
  end
end
