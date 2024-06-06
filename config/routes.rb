Rails.application.routes.draw do
  post '/register', to: 'user#register'
  post '/login', to: 'user#login'
  post '/logout', to: 'user#logout'

  # Defines the root path route ("/")
  # root "posts#index"
end
