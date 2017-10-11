FactoryGirl.define do
  factory :price do
    price 18
    monday false
    tuesday false
    wednesday false
    thursday false
    friday false
    saturday false
    sunday false
  end

  factory :filled_price, class: Price do
    price 10
    start_minute_of_a_day 0
    end_minute_of_a_day 1440
    monday true
    tuesday true
    wednesday true
    thursday true
    friday true
    saturday true
    sunday true
  end
end
