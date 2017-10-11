class AddCourtSurfaceToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :surface, :integer
  end
end
