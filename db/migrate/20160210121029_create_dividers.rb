class CreateDividers < ActiveRecord::Migration
  def change
    create_table :dividers do |t|
      t.references :price, index: true, foreign_key: true
      t.references :court, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
