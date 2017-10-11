class AddConfirmationMessageToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :confirmation_message, :text
  end
end
