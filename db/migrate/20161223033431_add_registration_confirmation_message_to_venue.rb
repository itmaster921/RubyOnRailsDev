class AddRegistrationConfirmationMessageToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :registration_confirmation_message, :text
  end
end
