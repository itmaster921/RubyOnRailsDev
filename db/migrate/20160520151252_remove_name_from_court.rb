class RemoveNameFromCourt < ActiveRecord::Migration
  def change
    remove_column :courts, :court_name
    add_column :courts, :index, :integer
  end
end
