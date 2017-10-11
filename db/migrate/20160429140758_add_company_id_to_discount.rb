class AddCompanyIdToDiscount < ActiveRecord::Migration
  def change
    add_reference :discounts, :company, index: true, foreign_key: true
  end
end
