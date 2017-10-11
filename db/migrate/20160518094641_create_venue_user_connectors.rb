class CreateVenueUserConnectors < ActiveRecord::Migration
  def change
    create_table :venue_user_connectors do |t|
      t.references :user, index: true, foreign_key: true
      t.references :venue, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
