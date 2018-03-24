FactoryBot.define do
  factory :pair do
    mini false

    trait :audusd do
      base "AUD"
      quote "USD"
      ig_epic "AUD.USD"
    end

    trait :eurusd do
      base "EUR"
      quote "USD"
      ig_epic "AUD.USD"
    end

    trait :mini do
      mini true
    end
  end
end
