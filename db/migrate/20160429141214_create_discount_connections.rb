class CreateDiscountConnections < ActiveRecord::Migration
  def change
    create_table :discount_connections do |t|
      t.references :discount, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
