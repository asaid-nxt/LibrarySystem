class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :borrowed_at, :due_date, presence: true

  scope :overdue, -> { where('due_date < ? AND returned_at IS NULL', Time.current) }
end
