class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.string :name
      t.integer :precentage

      t.timestamps null: false
    end
  end
end
