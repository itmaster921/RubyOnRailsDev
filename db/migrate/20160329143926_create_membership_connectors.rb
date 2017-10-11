class CreateMembershipConnectors < ActiveRecord::Migration
  def change
    create_table :membership_connectors do |t|
      t.references :membership, index: true, foreign_key: true
      t.references :reservation, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
