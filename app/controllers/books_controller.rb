class BooksController < ApplicationController
  before_action :set_book, only: [:update, :destroy, :show]
  before_action :authenticate_admin!, only: [:create, :update, :destroy]
  before_action :authenticate_user!, only: [:show_available_books]

  def index
    books = Book.by_genre(params[:genre])
    render json: books
  end

  def show_available_books
    available_books = Book.available
    render json:available_books
  end

  def show
    render json: @book
  end


  def create
    book = Book.new(book_params)

    if book.save
      render json: book, status: :created
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def update
    if @book.update(book_params)
      render json: @book, status: :ok
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @book.destroy
      head :no_content
    else
      render json: { error: 'Failed to delete book' }, status: :unprocessable_entity
    end
  end



  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn, :available_copies)
  end

end
