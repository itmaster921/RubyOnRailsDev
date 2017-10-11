class ChangeCompanyZipToString < ActiveRecord::Migration
  def change
    change_column :companies, :company_zip, :string
  end
end
