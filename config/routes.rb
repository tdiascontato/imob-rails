Rails.application.routes.draw do
  post 'register', to: 'user#register'

  # Defines the root path route ("/")
  # root "posts#index"
end
