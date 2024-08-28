FactoryBot.define do
  factory :book do
    title { "Sample Book Title" }
    author { "Sample Author" }
    genre { "Fiction" }
    isbn { "123-4567890123" }
    available_copies { 5 }
  end
end
