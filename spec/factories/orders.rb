FactoryBot.define do
  factory :order do
    pair

    direction "buy"
    entry 0.8
    size 1
    take_profit 0.9
    stop_loss 0.7

    transient do
      fx_signal nil
    end

    after(:create) do |order, evaluator|
      order.fx_signals << evaluator.fx_signal if evaluator.fx_signal
    end
    
  end
end
