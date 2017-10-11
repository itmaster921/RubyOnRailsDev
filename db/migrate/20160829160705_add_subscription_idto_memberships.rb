class AddSubscriptionIdtoMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :subscription_id, :string
  end

end
