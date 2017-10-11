class AddNameToGamePass < ActiveRecord::Migration
  def change
    add_column :game_passes, :name, :string
  end
end
