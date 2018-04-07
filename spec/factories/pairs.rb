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
      ig_epic "EUR.USD"
    end

    trait :gbpusd do
      base "GBP"
      quote "USD"
      ig_epic "GBP.USD"
    end

    trait :gbpjpy do
      base "GBP"
      quote "JPY"
      ig_epic "GBP.JPY"
    end

    trait :nzdusd do
      base "NZD"
      quote "USD"
      ig_epic "NZD.USD"
    end

    trait :nzdjpy do
      base "NZD"
      quote "JPY"
      ig_epic "NZD.JPY"
    end

    trait :chfjpy do
      base "CHF"
      quote "JPY"
      ig_epic "CHF.JPY"
    end

    trait :mini do
      mini true
    end
  end
end
