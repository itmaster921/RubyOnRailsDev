FactoryGirl.define do
  factory :day_off do
    start_time {DateTime.now.utc.change(hour: 6, minute: 0, second: 0)}
    end_time {start_time.advance(hours: 16)}

    trait :with_venue do
      association :place, factory: :venue
      place_type 'Venue'
    end

    trait :with_court do
      association :place, factory: :court
      place_type 'Court'
    end
  end
end
