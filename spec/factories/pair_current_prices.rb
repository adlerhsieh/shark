FactoryBot.define do
  factory :pair_current_price, class: 'Pair::CurrentPrice' do
    bid "9.99"
    offer "9.99"
    pair_id 1
  end
end
