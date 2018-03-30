FactoryBot.define do
  factory :blacklist_email, class: 'Blacklist::Email' do
    source "MyString"
    source_id "MyString"
  end
end
