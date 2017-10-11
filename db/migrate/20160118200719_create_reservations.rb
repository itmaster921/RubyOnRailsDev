class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :venue, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.datetime :date
      t.time :start_time
      t.time :end_time
      t.decimal :price
      t.decimal :total

      t.timestamps null: false
    end
  end
end
