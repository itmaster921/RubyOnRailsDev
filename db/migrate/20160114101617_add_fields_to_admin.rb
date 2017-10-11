class AddFieldsToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :admin_birth_day, :integer
    add_column :admins, :admin_birth_month, :integer
    add_column :admins, :admin_birth_year, :integer
    add_column :admins, :admin_ssn, :string
  end
end
