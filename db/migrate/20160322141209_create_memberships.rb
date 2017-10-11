class CreateMemberships < ActiveRecord::Migration

  def change
    create_table "memberships" do |t|
      t.datetime "end_time"
      t.datetime "start_time"
      t.integer  "user_id"
      t.integer  "venue_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.float    "price"
    end
  end
end
