FactoryBot.define do
  factory :source do
    name "Foobar"

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

  end
end

