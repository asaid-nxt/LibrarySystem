class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :borrowed_at, :due_date, presence: true
  validates :book_id, uniqueness: { scope: :user_id, message: 'has already been borrowed' }

  scope :overdue, -> { where('due_date < ? AND returned_at IS NULL', Time.current) }
end
