FactoryBot.define do
  factory :position do
    pair

    direction "buy"
    entry 0.8
    size 1
    take_profit 0.9
    stop_loss 0.7

    trait :closed do
      closed 0.9
      closed_at "2018-03-02 22:49:14"
    end

  end
end
