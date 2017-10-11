# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# admin1 = Admin.create email: "admin@ampersports.fi", password: "ampersports", first_name: "John", last_name: "Smith",
#                       admin_birth_day: 23, admin_birth_month: 1, admin_birth_year: 1971, admin_ssn: "131052-308T", level: 3

# admin2 = Admin.create email: "employee@ampersports.fi", password: "ampersports", first_name: "Jane", last_name: "Smith",
#                       admin_birth_day: 23, admin_birth_month: 1, admin_birth_year: 1971, admin_ssn: "131052-308T", level: 1

# company = Company.create company_legal_name: "Helsinki Tennis Company Ltd", company_country: "Finland",
#                          company_business_type: "Osakeyhtiö", company_tax_id: "FI10160923", company_street_address: "Eteläesplanadi 2",
#                          company_zip: "00130", company_city: "Helsinki", company_website: "www.tennis.fi", company_phone: "09 2255 093",
#                          company_iban: "DE89370400440532013000"

# company.admins << admin1
# company.admins << admin2

# venue = Venue.create company: company, venue_name: "Helsinki Tennisclub", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
#                      parking_info: "We have 8 parking spots that are available for no charge", transit_info: "Trams number 3 and 4 come to our venue from Helsinki center",
#                      street: "Eteläesplanadi 2", city: "Helsinki", zip: "00130", booking_ahead_limit: 30, listed: true, indoor_count: 3, outdoor_count: 3,
#                      business_hours: {"mon"=>{"opening"=>"07:00", "closing"=>"22:00"}, "tue"=>{"opening"=>"07:00", "closing"=>"22:00"},
#                      "wed"=>{"opening"=>"07:00", "closing"=>"22:00"}, "thu"=>{"opening"=>"07:00", "closing"=>"22:00"},
#                      "fri"=>{"opening"=>"07:00", "closing"=>"22:00"}, "sat"=>{"opening"=>"09:00", "closing"=>"22:00"},
#                      "sun"=>{"opening"=>"09:00", "closing"=>"22:00"}}

# court1 = Court.create court_name: "Indoor 1", sport_name: "Tennis", venue: venue, duration_policy: 1, start_time_policy: 1, active: true, indoor: true
# court2 = Court.create court_name: "Indoor 2", sport_name: "Tennis", venue: venue, duration_policy: 1, start_time_policy: 1, active: true, indoor: true
# court3 = Court.create court_name: "Indoor 3", sport_name: "Tennis", venue: venue, duration_policy: 1, start_time_policy: 1, active: true, indoor: true
# court4 = Court.create court_name: "Outdoor 1", sport_name: "Tennis", venue: venue, duration_policy: 1, start_time_policy: 2, active: true, indoor: false
# court5 = Court.create court_name: "Outdoor 2", sport_name: "Tennis", venue: venue, duration_policy: 1, start_time_policy: 2, active: true, indoor: false
# court6 = Court.create court_name: "Outdoor 3", sport_name: "Tennis", venue: venue, duration_policy: 1, start_time_policy: 2, active: true, indoor: false

# courts_indoor = []
# courts_indoor << court1 << court2 << court3
# courts_outdoor = []
# courts_oudoor << court4 << court5 << court6

# #weekday
# #indoor
# price1 = Price.create price: 20.0, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, start_minute_of_a_day: 420, end_minute_of_a_day: 540
# price2 = Price.create price: 18.0, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, start_minute_of_a_day: 540, end_minute_of_a_day: 900
# price3 = Price.create price: 28.0, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, start_minute_of_a_day: 900, end_minute_of_a_day: 1320
# #outdoor
# price4 = Price.create price: 20.0, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, start_minute_of_a_day: 450, end_minute_of_a_day: 570
# price5 = Price.create price: 18.0, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, start_minute_of_a_day: 570, end_minute_of_a_day: 930
# price6 = Price.create price: 28.0, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, start_minute_of_a_day: 930, end_minute_of_a_day: 1350
# #weekend
# #indoor
# price7 = Price.create price: 20.0, monday: false, tuesday: false, wednesday: false, thursday: false, friday: false, saturday: true, sunday: true, start_minute_of_a_day: 540, end_minute_of_a_day: 1320
# #outdoor
# price8 = Price.create price: 20.0, monday: false, tuesday: false, wednesday: false, thursday: false, friday: false, saturday: true, sunday: true, start_minute_of_a_day: 570, end_minute_of_a_day: 1350
# # outdoor 07:00 - 07:30 empty price
# price9 = Price.create price: 20.0, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, start_minute_of_a_day: 420, end_minute_of_a_day: 450
# # outdoor 09:00 - 09:30 weekend empty price
# price10 = Price.create price: 20.0, monday: false, tuesday: false, wednesday: false, thursday: false, friday: false, saturday: true, sunday: true, start_minute_of_a_day: 540, end_minute_of_a_day: 570

# courts_indoor.each do |c|
#   Divider.create(price: price1, court: c)
# end

# courts_indoor.each do |c|
#   Divider.create(price: price2, court: c)
# end

# courts_indoor.each do |c|
#   Divider.create(price: price3, court: c)
# end

# courts_indoor.each do |c|
#   Divider.create(price: price7, court: c)
# end

# courts_oudoor.each do |c|
#   Divider.create(price: price4, court: c)
# end

# courts_oudoor.each do |c|
#   Divider.create(price: price5, court: c)
# end

# courts_oudoor.each do |c|
#   Divider.create(price: price6, court: c)
# end

# courts_oudoor.each do |c|
#   Divider.create(price: price8, court: c)
# end

# courts_oudoor.each do |c|
#   Divider.create(price: price9, court: c)
# end

# courts_oudoor.each do |c|
#   Divider.create(price: price10, court: c)
# end

