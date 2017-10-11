class RemoveAdminInfoFromCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :company_admin_name
    remove_column :companies, :company_admin_birth_day
    remove_column :companies, :company_admin_birth_month
    remove_column :companies, :company_admin_birth_year
    remove_column :companies, :company_admin_country
    remove_column :companies, :company_admin_street_address
    remove_column :companies, :company_admin_zip
    remove_column :companies, :company_admin_city
  end
end
