Rails.application.routes.draw do
  post '/register', to: 'user#register'
  post '/login', to: 'user#login'
  post '/logout', to: 'user#logout'

  post '/work/register', to: 'work#register'

  get '/user/works', to: 'work#get_works'
  get 'storage/work_images/:filename', to: 'work#show_images', constraints: { filename: /[^\/]+/ }

  # Defines the root path route ("/")
  # root "posts#index"
end
