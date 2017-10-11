FactoryGirl.define do
  factory :court do
    sport_name :tennis
    court_description { generate(:description) }
    duration_policy 60
    start_time_policy 0
    active true
    association :venue, factory: :venue
    index 0
    indoor false
  end

  sequence :name do |n|
    "Court #{n}"
  end

  sequence :description do |n|
    "Court description #{n}"
  end

  trait :with_day_offs do
    transient do
      day_off_count 2
    end

    after(:create) do |court, evaluator|
      create_list(:day_off, evaluator.day_off_count, court: court)
    end
  end

  trait :with_prices do
    transient do
      price_count 1
    end

    after(:create) do |court, evaluator|
      create_list(:filled_price, evaluator.price_count, courts: [court])
    end
  end
end
