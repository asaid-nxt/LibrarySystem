FactoryBot.define do
  factory :admin do
    email { "admin@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
