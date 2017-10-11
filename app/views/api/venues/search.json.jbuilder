json.venues(@venues_data) do |venue|
  json.venue_id venue[:venue].id
  json.venue_name venue[:venue].venue_name
  json.website venue[:venue].website
  json.phone_number venue[:venue].phone_number
  json.street venue[:venue].street
  json.city venue[:venue].city
  json.supported_sports venue[:venue].supported_sports
  json.zip venue[:venue].zip
  json.url ('/venues/' + venue[:venue].id.to_s)
  json.image Venue.find(venue[:venue].id).photos.first.image.url
  json.data venue[:data]
end
