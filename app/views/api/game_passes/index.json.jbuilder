json.game_passes(@game_passes) do |gp|
  json.id gp.id
  json.user gp.user
  json.total_charges gp.total_charges
  json.remaining_charges gp.remaining_charges
  json.active gp.active.to_s
  json.price gp.price
  json.court_sports gp.court_sports_to_s
  json.court_type Court.human_attribute_name("court_name.#{gp.court_type}")
  json.dates_limit gp.dates_limit
  json.start_date gp.start_date_to_s
  json.end_date gp.end_date_to_s
  json.time_limitations gp.time_limitations_to_s
end
