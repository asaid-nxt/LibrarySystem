# spec/factories/borrowings.rb
FactoryBot.define do
  factory :borrowing do
    association :user
    association :book
    borrowed_at { Time.current }
    due_date { 2.weeks.from_now }
    returned_at { nil }
  end
end
