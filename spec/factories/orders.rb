FactoryBot.define do
  factory :order do
    pair

    direction "buy"
    entry 0.8
    size 1
    take_profit 0.9
    stop_loss 0.7
    
  end
end
