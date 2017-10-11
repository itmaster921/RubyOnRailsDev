class CreateCourtConnectors < ActiveRecord::Migration
  def change
    create_table :court_connectors do |t|
      t.references :court, index: true, foreign_key: true
      t.references :shared_court, index: true

      t.timestamps null: false
    end
  end
end
