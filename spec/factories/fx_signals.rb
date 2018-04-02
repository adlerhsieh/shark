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
        order = create(:order, 
                       pair: signal.pair,
                       source: signal.source,
                       direction: signal.direction,
                       entry: signal.entry,
                       take_profit: signal.take_profit,
                       stop_loss: signal.stop_loss,
                       expired_at: Time.now + 1.day
                      )
        order.fx_signals << signal
      end
    end

    trait :with_position do
      after(:create) do |signal|
        position = create(:position, 
                          pair: signal.pair,
                          source: signal.source,
                          direction: signal.direction,
                          entry: signal.entry,
                          take_profit: signal.take_profit,
                          stop_loss: signal.stop_loss,
                          opened_at: Time.current
                         )
        position.fx_signals << signal
      end
    end

  end
end
