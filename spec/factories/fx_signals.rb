FactoryBot.define do
  factory :fx_signal do
    pair

    trait :buy do
      direction "buy"
      entry 0.90
      take_profit 0.95
      stop_loss 0.85
    end

    trait :sell do
      direction "sell"
    end
    
  end
end
