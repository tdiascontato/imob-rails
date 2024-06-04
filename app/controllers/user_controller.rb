class UserController < ApplicationController
  def register
    email = params[:email]
    pass = params[:password]
    send = {email: email, password: pass}
    user = User.new(send)
    if user
      render json: {message: 'User registered!'}, status: 200
    else
      render json: {message: 'User didnt registered.. Sad'}, status: 422
    end
  end
end
