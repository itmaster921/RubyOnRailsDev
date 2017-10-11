# represents a Venue photo
class Photo < ActiveRecord::Base
  belongs_to :venue

  has_attached_file :image, styles: { medium: '300x300>#',
                                      thumb: '100x100>#' }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  after_create :make_primary

  def make_primary
    venue.set_primary_photo if venue.primary_photo_id.nil?
  end
end
