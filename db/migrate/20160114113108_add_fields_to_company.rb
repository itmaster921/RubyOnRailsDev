class AddFieldsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :company_iban, :string
  end
end
