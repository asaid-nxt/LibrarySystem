class Book < ApplicationRecord
  validates :title, :author, :genre, :isbn, :available_copies, presence: true
  scope :by_genre, ->(genre) {where("genre ILIKE ?", genre) if genre.present?}
end
