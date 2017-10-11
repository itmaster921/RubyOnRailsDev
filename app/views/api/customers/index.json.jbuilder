json.customers(@customers) do |customer|
  json.id customer.id
  json.first_name customer.first_name
  json.last_name customer.last_name
  json.email customer.email
  json.phone_number customer.phone_number
  json.city customer.city
  json.street_address customer.street_address
  json.zipcode customer.zipcode
  json.outstanding_balance @outstanding_balances[customer.id].to_f
  json.reservations_done @reservations[customer.id].try(:count).to_i
end

json.current_page @customers.current_page
json.total_pages @customers.total_pages
