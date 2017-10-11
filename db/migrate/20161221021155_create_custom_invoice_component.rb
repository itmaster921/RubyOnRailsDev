class CreateCustomInvoiceComponent < ActiveRecord::Migration
  def change
    create_table :custom_invoice_components do |t|
      t.belongs_to  :invoice, index: true, foreign_key: true
      t.decimal     :price, precision: 8, scale: 2
      t.boolean     :is_billed, null: false, default: false
      t.boolean     :is_paid, null: false, default: false
      t.string      :name
      t.decimal     :vat_decimal, precision: 6, scale: 5

      t.timestamps null: false
    end
  end
end
