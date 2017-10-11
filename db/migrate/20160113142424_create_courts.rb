class CreateCourts < ActiveRecord::Migration
  def change
    create_table :courts do |t|
      t.string :court_name
      t.string :sport_name
      t.text :court_description
      t.references :venue, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
