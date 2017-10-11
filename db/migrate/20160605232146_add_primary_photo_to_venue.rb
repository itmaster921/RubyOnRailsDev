class AddPrimaryPhotoToVenue < ActiveRecord::Migration
  def change
    add_reference :venues, :primary_photo, references: :photos
  end
end
