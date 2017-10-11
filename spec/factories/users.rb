FactoryGirl.define do
  sequence :phone_number do |n|
    1*(10**8) + n*(10**4) + n
  end

  factory :user do
    email { generate(:email) }
    password "12345678"
    password_confirmation "12345678"
    first_name { generate(:first_name) }
    last_name { generate(:last_name) }
    phone_number
    city 'Chikagostan'
    street_address 'Some address 5/6'
    zipcode '32454'
    confirmed_at DateTime.new
    uid { email }
    provider 'email'

    trait :with_venues do
      transient do
        venue_count 1
      end

      after(:create) do |user, evaluator|
        create_list(:venue, evaluator.venue_count, users: [user])
        user.reload
      end
    end
  end

  sequence :email do |n|
    "play_#{n}@mywebsite.com"
  end

  sequence :first_name do |n|
    "Play_#{n}"
  end

  sequence :last_name do |n|
    "Ven_#{n}"
  end

end
