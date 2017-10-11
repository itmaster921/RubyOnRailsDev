@templates.each do |template|
  json.set! template.id do
    json.id template.id
    json.name template.name
    json.template_name template.template_name
    json.total_charges template.total_charges
    json.price template.price
    json.court_sports template.court_sports
    json.court_type template.court_type
    json.start_date template.start_date_to_s
    json.end_date template.end_date_to_s
    json.time_limitations template.time_limitations
  end
end
