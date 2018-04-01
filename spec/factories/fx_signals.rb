FactoryBot.define do
  factory :fx_signal do
    pair
    source

    trait :buy do
      direction "buy"
      entry 0.90
      take_profit 0.95
      stop_loss 0.85
    end

    trait :sell do
      direction "sell"
    end

    trait :order do
      target_resource "Order"
    end

    trait :position do
      target_resource "Position"
    end

    trait :create do
      action "create"
    end

    trait :update do
      action "update"
    end

    trait :close do
      action "close"
    end

    trait :cancel do
      action "cancel"
    end

  end
end
