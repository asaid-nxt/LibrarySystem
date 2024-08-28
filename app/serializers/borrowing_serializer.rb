class BorrowingSerializer < ActiveModel::Serializer
  attributes :book_title, :borrowed_at, :returned_at

  def book_title
    object.book.title || "No Title Available"
  end
end
