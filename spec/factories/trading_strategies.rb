FactoryBot.define do
  factory :trading_strategy do

    trait :multi_level_tp do
      id 1
      name "multi_level_tp"
    end

    trait :constant do
      id 2
      name "constant"
    end

    trait :minimize_tp_sl do
      id 3
      name "minimize_tp_sl"
    end
  end
end
