class AddCourtCountsToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :court_counts, :text
  end
end
