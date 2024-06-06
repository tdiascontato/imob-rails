class UserController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]
  def register

    if params[:email].blank? || params[:password].blank?
      render json: { message: "Por favor informe 'email' and 'password'" }, status: 400 and return
    end

    begin
      email = params[:email]
      password = params[:password]
      user = User.new(email: email, password: password)

      if user.save
        log_action('Success Register', params)
        render json: { message: 'Usuário registrado!', data: user }, status: 200
      else
        log_action('Fail Register', params)
        render json: { message: "Usuário não registrado. Erro: #{user.errors.full_messages.join(', ')}" }, status: 422
      end
    rescue => e
      log_action('Fail Function Register', params)
      render json: { message: "Erro ao registrar: #{e.message}" }, status: 500
    end
  end

  def login

    if params[:email].blank? || params[:password].blank?
      render json: { message: "Por favor informe 'email' and 'password'" }, status: 400 and return
    end

    email = params[:email]
    password = params[:password]
    user = User.find_by(email: email)

    if user&.authenticate(password)
      token = JsonWebToken.encode(user_id: user._id)
      user.update(token: token)
      log_action('Sucess login', params)
      render json: { message: 'Login successful!', token: token }, status: 200
    else
      log_action('Fail login', params)
      render json: { message: 'Email ou password incorretos!' }, status: 401
    end
  end

  def logout
    if @current_user
      @current_user.update(token: nil)
      log_action('Success Logout', { user: @current_user })
      render json: { message: 'Logout successful!' }, status: 200
    else
      log_action('Fail Logout', { user: @current_user })
      render json: { message: 'Usuário não autenticado' }, status: 401
    end
  end

  private
  def log_action(action, body)
    Log.create(action: action, function: action_name, path: request.path, body: body.to_unsafe_h, user: @current_user)
  rescue => e
    Rails.logger.error("Failed to log action: #{e.message}")
  end
end