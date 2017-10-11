FactoryGirl.define do
  factory :reservation do
    price 20
    start_time { DateTime.current.advance(weeks: 2).beginning_of_week.at_noon }
    end_time { start_time.advance(hours: 1) }
    payment_type :unpaid
    booking_type :online
    association :user, factory: :user
    association :court, factory: :court

    factory :novalidate_reservation do
      to_create {|instance| instance.save(validate: false) }
    end
  end
end

