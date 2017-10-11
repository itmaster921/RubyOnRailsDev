json.membership do
  json.start_time TimeSanitizer.output(@membership.start_time).strftime('%H:%M')
  json.end_time TimeSanitizer.output(@membership.end_time)
    .try(:strftime, '%H:%M')
  json.start_date @membership.start_time.try(:strftime, '%d/%m/%Y')
  json.end_date @membership.end_time.try(:strftime, '%d/%m/%Y')
  json.price @membership.price
  json.update_url venue_membership_path(@membership.venue, @membership)
  json.court @membership.reservations.first.try(:court).try(:id)
  json.weekday @membership.reservations.first.try(:start_time).try(:strftime, '%A').try(:downcase)
end
