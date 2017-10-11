class AddGuestRecord < ActiveRecord::Migration
  def up
    Guest.create(full_name: "Guest", singleton: 0)
  end

  def down
    Guest.first.destroy
  end
end
