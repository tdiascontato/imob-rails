class UserController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]
  def register
    log_action('register', params)

    if params[:email].blank? || params[:password].blank?
      render json: { message: "Por favor informe 'email' and 'password'" }, status: 400 and return
    end

    begin
      email = params[:email]
      pass = params[:password]
      user = User.new(email: email)
      user.password = pass
      user.save!
      render json: { message: 'Usuário registrado!', data: user }, status: 200
    rescue => e
      render json: { message: "Usuário não registrado.. Error: #{e}"}, status: 405
    end
  end
  def login
    log_action('login', params)

    if params[:email].blank? || params[:password].blank?
      render json: { message: "Por favor informe 'email' and 'password'" }, status: 400 and return
    end

    email = params[:email]
    pass = params[:password]
    user = User.find_by(email: email)

    if user&.authenticate(pass)
      token = JsonWebToken.encode(user_id: user._id)
      render json: { message: 'Login successful!', token: token }, status: 200
    else
      render json: { message: 'Email ou password incorretos!' }, status: 401
    end
  end

  private
  def log_action(action, body)
    Log.create(action: action, function: action_name, path: request.path, body: body.to_unsafe_h, user: @current_user)
  rescue => e
    Rails.logger.error("Failed to log action: #{e.message}")
  end
end