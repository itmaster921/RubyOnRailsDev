json.array! @venues do |venue|
  json.id venue.id
  json.name truncate(venue.venue_name, length: 38)
  json.image venue.photos.first.image.url(:medium)
  json.street venue.street
  json.zip venue.zip
  json.city venue.city
  json.phone_number venue.phone_number
  json.website venue.website
  json.lowest_price venue.prices.map(&:price).sort.first.to_i
  json.url venue_path(venue.id)
end
