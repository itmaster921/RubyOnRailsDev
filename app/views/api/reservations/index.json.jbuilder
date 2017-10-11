json.future_reservations @reservations_future do |reservation|
  json.partial! 'reservation', reservation: reservation
end
json.past_reservations @reservations_past do |reservation|
  json.partial! 'reservation', reservation: reservation
end
json.future_memberships @subscriptions_future do |reservation|
  json.partial! 'reservation', reservation: reservation
end
json.past_memberships @subscriptions_past do |reservation|
  json.partial! 'reservation', reservation: reservation
end
json.reselling_memberships @subscriptions_reselling do |reservation|
  json.partial! 'reservation', reservation: reservation
end
json.resold_memberships @subscriptions_resold do |reservation|
  json.partial! 'reservation', reservation: reservation
end
