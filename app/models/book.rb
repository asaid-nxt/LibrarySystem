class Book < ApplicationRecord
  has_many :borrowings

  validates :title, :author, :genre, :isbn, :available_copies, presence: true
  validates :book_id, uniqueness: { scope: :user_id, message: 'has already been borrowed' }

  scope :by_genre, ->(genre) {where("genre ILIKE ?", genre) if genre.present?}
  scope :available, -> { where('available_copies > 0') }

  def borrowable?
    available_copies > 0
  end

  def borrow!
    if borrowable?
      decrement!(:available_copies)
    else
      errors.add(:base, 'No copies available')
    end
  end

  def return!
    increment!(:available_copies)
  end
end
