class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.float :price
      t.time :start_time
      t.time :end_time
      t.string :day
      t.references :court, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
