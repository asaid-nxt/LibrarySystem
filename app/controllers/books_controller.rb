class BooksController < ApplicationController
  def index
    @books = Book.by_genre(params[:genre])
    render json: @books
  end
end
