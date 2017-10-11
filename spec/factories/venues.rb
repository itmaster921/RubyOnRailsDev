FactoryGirl.define do
  factory :venue do
    venue_name "Test Venue"
    latitude "60.175405"
    longitude "24.914562"
    description "Best Tennis Place In THe World"
    parking_info "You can park here"
    transit_info "Busses come here"
    website "www.tenniscompany.com"
    phone_number "+35840934052834"
    street "Mannerheimintie 5"
    city "Helsinki"
    zip "00100"
    booking_ahead_limit 365
    business_hours do
      { mon: { opening: 21_600.0, closing: 79_200.0 },
        tue: { opening: 21_600.0, closing: 79_200.0 },
        wed: { opening: 21_600.0, closing: 79_200.0 },
        thu: { opening: 21_600.0, closing: 79_200.0 },
        fri: { opening: 21_600.0, closing: 79_200.0 },
        sat: { opening: 21_600.0, closing: 79_200.0 },
        sun: { opening: 21_600.0, closing: 79_200.0 } }
    end
    association :company, factory: :company

    trait :with_courts do
      transient do
        court_count 2
      end

      after(:create) do |venue, evaluator|
        create_list(:court, evaluator.court_count, :with_prices, venue: venue)
      end
    end

    trait :with_memberships do
      transient do
        membership_count 2
      end

      after(:create) do |venue, evaluator|
        create_list(:membership, evaluator.membership_count, :with_user, venue: venue)
      end
    end

    trait :with_users do
      transient do
        user_count 1
      end

      after(:create) do |venue, evaluator|
        create_list(:user, evaluator.user_count, venues: [venue])
      end
    end
  end
end
