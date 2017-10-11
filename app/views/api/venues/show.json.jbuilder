  json.venue_id @venue.id
  json.venue_name @venue.venue_name
  json.website @venue.website
  json.phone_number @venue.phone_number
  json.street @venue.street
  json.city @venue.city
  json.zip @venue.zip
  json.lowprice @venue.courts.active.map{ |c| c.prices.map(&:price)}.flatten.uniq.sort.first
  json.highprice @venue.courts.active.map{ |c| c.prices.map(&:price)}.flatten.uniq.sort.last
  json.image Venue.find(@venue.id).photos.first.image.url
  json.transit_info @venue.transit_info
  json.parking_info @venue.parking_info
  json.description @venue.description
  json.business_hours @venue.business_hours
  json.longitude @venue.longitude
  json.supported_sports @venue.supported_sports
  json.latitude @venue.latitude
  json.thumbnails Venue.find(@venue.id).photos.limit(3) do |p|
    json.image_url p.image.url(:thumb)
  end
  json.images Venue.find(@venue.id).photos do |p|
    json.image_url p.image.url(:medium)
  end
