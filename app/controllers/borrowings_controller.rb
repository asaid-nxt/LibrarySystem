class BorrowingsController < ApplicationController
  before_action :authenticate_user!

  def create
    book = Book.find(params[:book_id])
    if book.borrowable?
      borrowing = current_user.borrowings.new(book: book, borrowed_at: Time.current, due_date: 2.weeks.from_now)

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
      borrowing.book.return! # Increase available_copies
      render json: { message: 'Book returned successfully' }, status: :ok
    else
      render json: { error: 'Borrowing record not found or already returned' }, status: :not_found
    end
  end

  
  def overdue
    overdue_books = current_user.borrowings.overdue
    render json: overdue_books, status: :ok
  end


end
