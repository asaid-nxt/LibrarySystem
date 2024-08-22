class Book < ApplicationRecord
  scope :by_genre, ->(genre) {where("genre ILIKE ?", genre) if genre.present?}
end
