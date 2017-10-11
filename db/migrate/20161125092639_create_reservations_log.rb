class CreateReservationsLog < ActiveRecord::Migration
  def change
    create_table :reservations_logs do |t|
      t.references :reservation, index: true, foreign_key: true
      t.integer   :status
      t.text      :params

      t.timestamps null: false
    end
  end
end
