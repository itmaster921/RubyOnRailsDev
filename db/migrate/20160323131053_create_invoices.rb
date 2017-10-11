class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.boolean :is_draft, null: false, default: true

      t.timestamps null: false
    end
  end
end
