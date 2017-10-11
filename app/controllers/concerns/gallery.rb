module Gallery
  extend ActiveSupport::Concern

  def gallery_images(venue)
    venue.photos.map do |p|
      p_json = p.attributes
      p_json['url'] = p.image.url(:thumb)
      p_json['delete_url'] = venue_photo_path(venue, p)
      p_json['main_url'] = venue_photo_make_primary_path(venue, p)
      p_json['main'] = venue.primary_photo_id == p.id
      p_json
    end
  end
end
