class AddPaymentMethodToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :invoice_by_cc, :boolean, default: false
  end
end
