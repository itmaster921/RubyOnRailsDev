class AddMoreStripeDetailsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :publishable_key, :string
    add_column :companies, :secret_key, :string
    add_column :companies, :currency, :string
    add_column :companies, :stripe_account_type, :string
    add_column :companies, :stripe_account_status, :string, default: "{}"
  end
end
