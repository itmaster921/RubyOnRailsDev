class AddOptionsToGamePass < ActiveRecord::Migration
  def change
    add_column :game_passes, :template_name, :string
    add_column :game_passes, :court_sports, :string
    add_column :game_passes, :court_type, :integer, default: 0
    add_column :game_passes, :time_limitations, :text
    add_column :game_passes, :start_date, :date
    add_column :game_passes, :end_date, :date
  end
end
