class AddStripeIdtoCompany < ActiveRecord::Migration
  def change
    add_column :companies, :stripe_user_id, :string
  end
end
