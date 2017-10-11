class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :venue_name
      t.float :latitude
      t.float :longitude
      t.text :description
      t.text :parking_info
      t.text :transit_info
      t.string :website
      t.string :phone_number
      t.time :monday_opening_time
      t.time :tuesday_opening_time
      t.time :wednesday_opening_time
      t.time :thursday_opening_time
      t.time :friday_opening_time
      t.time :saturday_opening_time
      t.time :sunday_opening_time
      t.time :monday_closing_time
      t.time :tuesday_closing_time
      t.time :wednesday_closing_time
      t.time :thursday_closing_time
      t.time :friday_closing_time
      t.time :saturday_closing_time
      t.time :sunday_closing_time
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
