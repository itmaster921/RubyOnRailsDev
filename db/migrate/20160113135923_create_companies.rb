class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :company_legal_name
      t.string :company_country
      t.string :company_business_type
      t.string :company_tax_id
      t.string :company_street_address
      t.integer :company_zip
      t.string :company_city
      t.string :company_website
      t.string :company_admin_name
      t.integer :company_admin_birth_day
      t.integer :company_admin_birth_month
      t.integer :company_admin_birth_year
      t.string :company_admin_country
      t.string :company_admin_street_address
      t.integer :company_admin_zip
      t.string :company_admin_city
      t.string :company_phone
      t.references :admin, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
