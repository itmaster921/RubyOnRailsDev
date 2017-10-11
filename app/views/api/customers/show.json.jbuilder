json.id @customer.id
json.first_name @customer.first_name.to_s
json.last_name @customer.last_name.to_s
json.email @customer.email.to_s
json.phone_number @customer.phone_number.to_s
json.city @customer.city.to_s
json.street_address @customer.street_address.to_s
json.zipcode @customer.zipcode.to_s
json.outstanding_balance @outstanding_balance.to_f
json.reservations_done @reservations.try(:count).to_i
json.last_reservation TimeSanitizer.strftime(@reservations.try(:last).try(:start_time), :date)
json.lifetime_value @lifetime_balance.to_f
