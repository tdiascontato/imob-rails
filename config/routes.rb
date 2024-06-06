Rails.application.routes.draw do
  post '/register', to: 'user#register'
  post '/login', to: 'user#login'

  # Defines the root path route ("/")
  # root "posts#index"
end
