class BorrowingsController < ApplicationController
  before_action :authenticate_user!

  def create
    book = Book.find(params[:book_id])
    if book.borrowable?
      borrowed_at = params[:borrowed_at].present? ? Time.parse(params[:borrowed_at]) : Time.current
      due_date = borrowed_at + 2.weeks

      if current_user.borrowings.exists?(book: book)
        render json: { error: 'You have already borrowed this book' }, status: :unprocessable_entity
        return
      end

      borrowing = current_user.borrowings.new(book: book, borrowed_at: borrowed_at, due_date: due_date)

      if borrowing.save
        book.borrow!
        render json: borrowing, status: :created
      else
        render json: { errors: borrowing.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Book is not available for borrowing' }, status: :unprocessable_entity
    end
  end



  def return
    borrowing = current_user.borrowings.find_by(book_id: params[:book_id], returned_at: nil)

    if borrowing
      borrowing.update(returned_at: Time.current)
      borrowing.book.return!
      render json: { message: 'Book returned successfully' }, status: :ok
    else
      render json: { error: 'Borrowing record not found or already returned' }, status: :not_found
    end
  end


  def overdue
    overdue_books = current_user.borrowings.overdue
    render json: overdue_books, status: :ok
  end


  def user
    borrowings = current_user.borrowings.includes(:book)
    render json: borrowings, each_serializer: BorrowingSerializer
  end

end
