class CreateEmailLists < ActiveRecord::Migration
  def change
    create_table :email_lists do |t|
      t.string :name
      t.references :venue, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
