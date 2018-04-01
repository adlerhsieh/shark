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

    trait :with_order do
      after(:create) do |signal|
        create(:order, 
               pair: signal.pair,
               source: signal.source,
               direction: signal.direction,
               entry: signal.entry,
               take_profit: signal.take_profit,
               stop_loss: signal.stop_loss,
               signal_id: signal.id,
               expired_at: Time.now + 1.day
              )
      end
    end

    trait :with_position do
      after(:create) do |signal|
        create(:position, 
               pair: signal.pair,
               source: signal.source,
               direction: signal.direction,
               entry: signal.entry,
               take_profit: signal.take_profit,
               stop_loss: signal.stop_loss,
               signal_id: signal.id,
               opened_at: Time.current
              )
      end
    end

  end
end
