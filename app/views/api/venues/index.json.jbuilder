json.venues(@venues) do |venue|
  json.id venue.id
  json.venue_name venue.venue_name
  json.website venue.website
  json.phone_number venue.phone_number
  json.street venue.street
  json.city venue.city
  json.supported_sports venue.supported_sports
  json.zip venue.zip
  json.url api_venue_path(venue, format: :json)
  json.image venue.try_photo_url
  json.lowest_price venue.prices.map(&:price).sort.first.to_i
end
