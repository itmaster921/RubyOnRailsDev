FactoryGirl.define do
  factory :membership, class: Membership do
    start_time Time.current.advance(weeks: -2).change(hour: 10).utc
    end_time {start_time.advance(months: 1, hours:1)}
    price 20

    trait :with_user do
      association :user, factory: :user
    end

    trait :with_venue do
      association :venue, factory: [:venue, :with_courts]
    end

    trait :with_reservations do
      transient do
        reservation_count 2
      end

      after(:create) do |membership, evaluator|
        create_list(:reservation, evaluator.reservation_count, :with_user, :with_court, membership: membership)
      end
    end

  end
end
