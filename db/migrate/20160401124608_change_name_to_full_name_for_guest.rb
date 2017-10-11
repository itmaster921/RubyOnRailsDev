class ChangeNameToFullNameForGuest < ActiveRecord::Migration
  def change
    rename_column :guests, :name, :full_name
  end
end
