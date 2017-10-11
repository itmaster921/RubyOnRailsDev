class CreateGamePasses < ActiveRecord::Migration
  def change
    create_table :game_passes do |t|
      t.integer :total_charges
      t.integer :remaining_charges
      t.decimal :price
      t.boolean :active, default: false
      t.references :user, index: true, foreign_key: true
      t.references :venue, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
