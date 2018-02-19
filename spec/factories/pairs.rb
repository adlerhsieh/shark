FactoryBot.define do
  factory :pair do
    mini false

    trait :audusd do
      base "AUD"
      quote "USD"
      ig_epic "AUD.USD"
    end
  end
end
