json.sportnames @sport_names do |sport|
  json.sport sport['name']
  json.url {
    json.active sport['url_active']
    json.inactive sport['url_inactive']
  }
end
