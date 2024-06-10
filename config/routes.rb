# config/routes.rb
Rails.application.routes.draw do
  # Registro,Login e Logout
  post '/register', to: 'user#register'
  post '/login', to: 'user#login'
  post '/logout', to: 'user#logout'
  # Registro, view, Update e Delete de Works
  post '/work/register', to: 'work#register'
  get '/user/works', to: 'work#get_works'
  patch '/user/works/:_id', to: 'work#update'
  delete '/user/works/:_id', to: 'work#delete'
  # Get de User, Update de User, Delete de User
  get '/user/perfil', to: 'user#get_user'
  patch '/user/perfil', to: 'user#update'
  delete '/user/delete', to: 'user#user_delete'

end
