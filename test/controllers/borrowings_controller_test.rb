require 'test_helper'

class BorrowingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "test_user@example.com", password: "password123")
    @book = Book.create!(title: "Sample Book", author: "Author Name", genre: "Fiction", isbn: "1234567890", available_copies: 1)
    sign_in @user
  end

  # Test for creating a borrowing
  test "should create borrowing" do
    assert_difference('Borrowing.count', 1) do
      post book_borrowings_path(@book), params: { book_id: @book.id }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(@response.body)
    assert json_response.key?('id')
    assert_equal @book.id, json_response['book_id']
    assert json_response.key?('borrowed_at')
    assert json_response.key?('due_date')
    assert_nil json_response['returned_at']
  end

  test "should not create borrowing if not logged in" do
    sign_out @user

    assert_no_difference('Borrowing.count') do
      post book_borrowings_path(@book), params: { book_id: @book.id }, as: :json
    end

    assert_response :unauthorized
    json_response = JSON.parse(@response.body)
    assert_equal 'You need to sign in or sign up before continuing.', json_response['error']
  end

  test "should not create borrowing if book not available" do
    @book.update(available_copies: 0) # Make the book unavailable

    assert_no_difference('Borrowing.count') do
      post book_borrowings_path(@book), params: { book_id: @book.id }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(@response.body)
    assert_equal 'Book is not available for borrowing', json_response['error']
  end

  # Test for returning a book
  test "should return borrowed book" do
    borrowing = @user.borrowings.create!(book: @book, borrowed_at: Time.current, due_date: 2.weeks.from_now)

    patch return_book_borrowing_path(@book, borrowing), as: :json

    assert_response :ok
    json_response = JSON.parse(@response.body)
    assert_equal 'Book returned successfully', json_response['message']
    assert_not_nil borrowing.reload.returned_at
    assert_equal @book.available_copies + 1, @book.reload.available_copies
  end

  test "should not return book if not borrowed or already returned" do
    patch return_book_borrowing_path(@book, id: 999), as: :json

    assert_response :not_found
    json_response = JSON.parse(@response.body)
    assert_equal 'Borrowing record not found or already returned', json_response['error']
  end

  # Test for listing overdue books
  test "should list overdue borrowings" do
    overdue_borrowing = @user.borrowings.create!(book: @book, borrowed_at: 1.month.ago, due_date: 1.month.ago)

    get overdue_book_borrowings_path(@book), as: :json

    assert_response :ok
    json_response = JSON.parse(@response.body)
    assert json_response.is_a?(Array)
    assert json_response.any? { |b| b['id'] == overdue_borrowing.id }
  end
end
