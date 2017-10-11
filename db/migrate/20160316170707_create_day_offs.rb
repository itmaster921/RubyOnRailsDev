class CreateDayOffs < ActiveRecord::Migration
  def change
    create_table :day_offs do |t|
      t.date :date
      t.references :place, index: true, polymorphic: true

      t.timestamps null: false
    end
  end
end
