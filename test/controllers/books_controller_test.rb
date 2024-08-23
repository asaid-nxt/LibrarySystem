require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    Book.delete_all

    @fiction_book = Book.create!(title: "Fiction Book", author: "Author 1", genre: "Fiction", isbn: "1234567890", available_copies: 5)
    @non_fiction_book = Book.create!(title: "Non-Fiction Book", author: "Author 2", genre: "Non-Fiction", isbn: "0987654321", available_copies: 3)

    @admin = Admin.create!(email: "admin@example.com", password: "password123")
    @non_admin_user = User.create!(email: "user@example.com", password: "password123")
  end

  # Test case for index action
  test "should get all books" do
    get books_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 2, json_response.length
  end

  # Test case for showing a specific book
  test "should show a specific book" do
    get book_url(@fiction_book), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @fiction_book.title, json_response["title"]
    assert_equal @fiction_book.author, json_response["author"]
    assert_equal @fiction_book.genre, json_response["genre"]
    assert_equal @fiction_book.isbn, json_response["isbn"]
    assert_equal @fiction_book.available_copies, json_response["available_copies"]
  end

  # Test case for filtering books by genre
  test "should get books filtered by genre" do
    get books_url(genre: "Fiction"), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal @fiction_book.title, json_response[0]["title"]
  end

  # Test case for creating a book with valid admin authentication
  test "should create a book with valid admin credentials" do
    sign_in @admin  # Sign in as an admin

    post books_url, params: { book: { title: "New Book", author: "New Author", genre: "Science", isbn: "1122334455", available_copies: 10 } }, as: :json
    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "New Book", json_response["title"]
    assert_equal "New Author", json_response["author"]
  end

  # Test case for creating a book with invalid admin authentication
  test "should not create a book with invalid admin credentials" do
    sign_in @non_admin_user  # Sign in as a non-admin user

    post books_url, params: { book: { title: "New Book", author: "New Author", genre: "Science", isbn: "1122334455", available_copies: 10 } }, as: :json
    assert_response :unauthorized  # or another appropriate response based on your setup
  end

  # Test case for creating a book without being signed in
  test "should not create a book without being signed in" do
    post books_url, params: { book: { title: "New Book", author: "New Author", genre: "Science", isbn: "1122334455", available_copies: 10 } }, as: :json
    assert_response :unauthorized  # or another appropriate response based on your setup
  end

  # Test case for updating a book with valid admin authentication
  test "should update a book with valid admin credentials" do
    sign_in @admin  # Sign in as an admin

    patch book_url(@fiction_book), params: { book: { title: "Updated Fiction Book", author: "Updated Author" } }, as: :json
    assert_response :ok

    json_response = JSON.parse(response.body)
    assert_equal "Updated Fiction Book", json_response["title"]
    assert_equal "Updated Author", json_response["author"]
  end

  # Test case for updating a book with invalid admin authentication
  test "should not update a book with invalid admin credentials" do
    sign_in @non_admin_user  # Sign in as a non-admin user

    patch book_url(@fiction_book), params: { book: { title: "Updated Fiction Book", author: "Updated Author" } }, as: :json
    assert_response :unauthorized  # or another appropriate response based on your setup
  end

  # Test case for updating a book without being signed in
  test "should not update a book without being signed in" do
    patch book_url(@fiction_book), params: { book: { title: "Updated Fiction Book", author: "Updated Author" } }, as: :json
    assert_response :unauthorized  # or another appropriate response based on your setup
  end

   # Test case for deleting a book with valid admin authentication
  test "should delete a book with valid admin credentials" do
    sign_in @admin  # Sign in as an admin

    assert_difference('Book.count', -1) do
      delete book_url(@fiction_book), as: :json
      assert_response :no_content
    end
  end

  # Test case for deleting a book with invalid admin authentication
  test "should not delete a book with invalid admin credentials" do
    sign_in @non_admin_user  # Sign in as a non-admin user

    delete book_url(@fiction_book), as: :json
    assert_response :unauthorized  # or another appropriate response based on your setup
  end

  # Test case for deleting a book without being signed in
  test "should not delete a book without being signed in" do
    delete book_url(@fiction_book), as: :json
    assert_response :unauthorized  # or another appropriate response based on your setup
  end
end
