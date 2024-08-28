## Library System API Documentation

This document provides comprehensive details about the Library System API built with Rails 7.

**1. System Architecture**

**Overview:**

- The system consists of a Rails API backend.
- Users (regular users and admins) interact with the system through API endpoints.
- The API interacts with a database to store information about books, users, borrowings, and other relevant data.

**Data Flow:**

1. User sends requests to API endpoints.
2. API validates requests and interacts with the database.
3. Database processes requests and updates data.
4. API responds to the user with requested data or success/error messages.

**Technology Stack:**

- **Backend:** Rails 7
- **Database:** PostgreSQL
- **Testing:** RSpec
- **API Documentation:** RSwag (for generating OpenAPI spec)
- **Authentication:** Devise

**Database Schema:**

The system utilizes the following tables:

- **admins:** Stores information about system administrators (email, password)
- **books:** Stores information about books (title, author, genre, ISBN, available copies)
- **borrowings:** Stores borrowing records (user, book, borrowed_at, due_date, returned_at)
- **users:** Stores information about registered users (email, password)

**API Endpoints:**

**Books Controller:**

- **GET /books:** Lists books (with optional filtering by genre and pagination).
- **GET /books/:id:** Shows details of a specific book.
- **POST /books (Admin only):** Creates a new book.
- **PUT /books/:id (Admin only):** Updates an existing book.
- **DELETE /books/:id (Admin only):** Deletes a book.
- **GET /books/available:** Lists available books.
- **GET /books/borrowed:** Lists borrowed books.

**Borrowings Controller:**

- **POST /books/:book_id/borrowings:** Borrows a book (user authentication required).
- **PATCH /books/:book_id/borrowings/return:** Returns a borrowed book (user authentication required).
- **GET /borrowings/overdue:** Lists overdue borrowed books for the current user (user authentication required).
- **GET /borrowings/user:** Lists all borrowed books for the current user (user authentication required).

**Authentication and Authorization:**

The API uses Devise for user authentication and authorization. Users can register, log in, and reset their passwords through the `users` endpoints:

- **POST /users:** Registers a new user.
- **POST /users/sign_in:** Logs in a user.
- **DELETE /users/sign_out:** Logs out a user.
- **PUT /users/password:** Resets a user's password.

Admins can register, log in, and reset their passwords through the `admins` endpoints:

- **POST /admins:** Registers a new admin.
- **POST /admins/sign_in:** Logs in an admin.
- **DELETE /admins/sign_out:** Logs out an admin.
- **PUT /admins/password:** Resets an admin's password.

**2. Setup Instructions**

**Prerequisites:**

- Ruby (version required by Rails 7)
- PostgreSQL database server
- Rails development environment

**Installation:**

1. Clone the project repository.
2. Install required gems: `bundle install`
3. Configure database connection details in `config/database.yml`.
4. Create the database tables: `rails db:migrate`

**3. User Guides**


**API Documentation:**

In addition to the API endpoints described above, your Library System API provides a built-in API documentation interface powered by RSwag. This interface allows you to easily view and test all available endpoints.

To access the API documentation, navigate to the following URL in your web browser:

```
http://your-api-base-url/api-docs
```

Replace `your-api-base-url` with the actual base URL of your API.

The API documentation interface provides a user-friendly interface for exploring endpoints, viewing their parameters and responses, and making test requests. You can use the interface to:

- **Browse available endpoints:** View a list of all available API endpoints and their HTTP methods.
- **View endpoint details:** Click on an endpoint to see its parameters, request body examples, and response schema.
- **Make test requests:** Use the built-in request form to send test requests and inspect the responses.

By using the RSwag documentation interface, you can quickly and easily understand and interact with your Library System API.


**Authentication:**

- Users can register, log in, and reset their passwords through the `users` endpoints.
- Admins can register, log in, and reset their passwords through the `admins` endpoints.
- The API utilizes token-based authentication for authorized requests. Refer to the frontend application documentation for authentication details.

**Available Endpoints:**

**Books:**

- **GET /books:**
    - Retrieve a list of books. Optionally filter by genre using the `genre` query parameter. Paginate results using `page` and `per_page` parameters (defaults to 10 books per page).
    - Example request: `GET /books?genre=fiction&page=2`
- **GET /books/:id:**
    - Get details of a specific book by its ID.
    - Example request: `GET /books/1`
- **POST /books (Admin only):**
    - Create a new book with title, author, genre, ISBN, and available copies information. Requires admin authentication.
    - Example request (using a tool like Postman):
        - Set request method to POST
        - Set URL to `http://localhost:3000/books` (replace with your API endpoint)
        - Include admin authentication token in the header (refer to frontend documentation)
        - Provide book details in JSON format in the request body.
- **GET /books/available:**
    - Retrieve a list of available books.
- **GET /books/borrowed:**
    - Retrieve a list of borrowed books.

**Borrowings:**

- **POST /books/:book_id/borrowings:**
    - Borrow a book by providing the book ID. Requires user authentication.
    - Optionally include `borrowed_at` in the request body to specify the borrowing date/time (defaults to current time).
    - Example request (using Postman):
        - Set request method to POST
        - Set URL to `http://localhost:3000/books/1/borrowings` (replace with your API endpoint)
        - Include user authentication token in the header
- **PATCH /books/:book_id/borrowings/return:**
    - Return a borrowed book by providing the book ID. Requires user authentication.
    - Example request (using Postman):
        - Set request method to PATCH
        - Set URL to `http://localhost:3000/books/1/borrowings/return` (replace with your API endpoint)
        - Include user authentication token in the header
- **GET /borrowings/overdue:**
    - Retrieve a list of overdue borrowed books for the current user. Requires user authentication.
- **GET /borrowings/user:**
    - Retrieve a list of all borrowed books for the current user. Requires user authentication.
