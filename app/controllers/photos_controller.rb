# Handle venue photo operations
class PhotosController < ApplicationController
  include Gallery

  def create
    @venue = Venue.find(params[:venue_id])
    @venue.photos.create(image: params[:file])
    render json: { images: gallery_images(@venue) }, status: :ok
  end

  def destroy
    photo = Photo.find(params[:id]).destroy
    venue = Venue.find(params[:venue_id])
    venue.set_primary_photo if venue.primary_photo_id == photo.id
    render json: { images: gallery_images(venue) }, status: :ok
  end

  # user primary_photo_id not primary_photo
  # otherwise corrupt data
  def make_primary
    photo = Photo.find(params[:photo_id])
    photo.venue.update_attributes(primary_photo_id: photo.id)
    render json: { images: gallery_images(photo.venue) },
           status: :ok
  end
end
