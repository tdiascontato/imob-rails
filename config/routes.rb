# config/routes.rb
Rails.application.routes.draw do
  post '/register', to: 'user#register'
  post '/login', to: 'user#login'
  post '/logout', to: 'user#logout'

  post '/work/register', to: 'work#register'

  get '/user/works', to: 'work#user_works'
  get '/user/perfil', to: 'user#get_user'
  patch '/user/perfil', to: 'user#patch_user'
  post '/user/delete', to: 'user#user_delete'

  get 'storage/work_images/:filename', to: 'work#work_images', constraints: { filename: /[^\/]+/ }

end
