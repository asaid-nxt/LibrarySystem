Rails.application.routes.draw do
  devise_for :admins, controllers: {
  sessions: 'admins/sessions',
  registrations: 'admins/registrations',
  passwords: 'admins/passwords'
  }

  devise_for :users, controllers: {
  sessions: 'users/sessions',
  registrations: 'users/registrations',
  passwords: 'users/passwords'
  }

  root to: redirect('/api-docs')

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'


  resources :books do
    collection do
      get 'available', to: 'books#show_available_books'
      get 'borrowed', to: 'books#show_borrowed_books'
    end
    resources :borrowings, only: [:create] do
      patch :return, on: :collection
    end
  end

  resources :borrowings, only: [] do
    collection do
      get :overdue
      get :user
    end
  end


  get "up" => "rails/health#show", as: :rails_health_check
end
