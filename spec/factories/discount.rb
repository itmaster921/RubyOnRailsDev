FactoryGirl.define do
  factory :discount do
    name { generate(:name) }
    value 50
    round nil
    add_attribute :method, :percentage
    association :venue, factory: :venue
  end
end
