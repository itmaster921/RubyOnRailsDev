class AddAdminLevelToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :level, :integer
  end
end
