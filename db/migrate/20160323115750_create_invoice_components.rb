class CreateInvoiceComponents < ActiveRecord::Migration
  def change
    create_table :invoice_components do |t|
      t.belongs_to :reservation, index: true, foreign_key: true
      t.decimal :price, precision: 8, scale: 2
      t.boolean :is_paid, null: false, default: false

      t.timestamps null: false
    end
  end
end
