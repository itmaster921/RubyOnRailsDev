class AddPoliciesToCourt < ActiveRecord::Migration
  def change
    add_column :courts, :duration_policy, :integer
    add_column :courts, :start_time_policy, :integer
  end
end
