FactoryBot.define do
  factory :audit_log do
    source_type 1
    source_id 1
    content "MyText"
  end
end
