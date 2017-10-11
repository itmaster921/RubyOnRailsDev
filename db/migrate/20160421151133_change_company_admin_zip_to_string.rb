class ChangeCompanyAdminZipToString < ActiveRecord::Migration
  def change
    change_column :companies, :company_admin_zip, :string
  end
end
