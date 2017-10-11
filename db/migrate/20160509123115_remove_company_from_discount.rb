class RemoveCompanyFromDiscount < ActiveRecord::Migration
  def change
    remove_column :discounts, :company_id
  end
end
