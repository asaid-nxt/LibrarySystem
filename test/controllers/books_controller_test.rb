require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    Book.delete_all
    @fiction_book = Book.create!(title: "Fiction Book", author: "Author 1", genre: "Fiction", isbn: "1234567890", available_copies: 5)
    @non_fiction_book = Book.create!(title: "Non-Fiction Book", author: "Author 2", genre: "Non-Fiction", isbn: "0987654321", available_copies: 3)
  end

  test "should get all books" do
    get books_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 2, json_response.length
  end

  test "should get books filtered by genre" do
    get books_url(genre: "Fiction"), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal @fiction_book.title, json_response[0]["title"]
  end
end
