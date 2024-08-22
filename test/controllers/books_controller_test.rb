require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    Book.delete_all
    @book1 = Book.create!(title: "Book 1", author: "Author 1", genre: "Fiction", isbn: "1234567890", available_copies: 5)
    @book2 = Book.create!(title: "Book 2", author: "Author 2", genre: "Non-Fiction", isbn: "0987654321", available_copies: 3)
  end

  test "should get index" do
    get books_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)

    assert_equal 2, json_response.length

    assert_equal @book1.title, json_response[0]["title"]
    assert_equal @book2.title, json_response[1]["title"]
  end
end
