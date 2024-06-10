# app/controllers/user_controller.rb
class UserController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]

  def get_user

    render json: { user: @current_user }, status:200
  end

  def register

    if params[:email].blank? || params[:password].blank? || params[:name].blank? || params[:image].blank?
      render json: { message: "Por favor informe 'email', 'password' and 'name'" }, status: 400 and return
    end

    begin
      name = params[:name]
      email = params[:email]
      password = params[:password]
      image_file = params[:image]

      image_path = save_image(image_file)
      image_path = request.base_url + image_path

      user = User.new(name: name, email: email, password: password, image: image_path)
      token = JsonWebToken.encode(user_id: user._id)
      user.update_attribute(:token, token)

      if user.save
        log_action('Success Register', {params: params})
        render json: { message: 'Usuário registrado!', token: user.token }, status: 200
      else
        log_action('Fail Register', { email: email, password: password })
        render json: { message: "Usuário não registrado. Erro: #{user.errors.full_messages.join(', ')}" }, status: 422
      end
    rescue => e
      log_action('Fail Function Register', { email: email, password: password })
      render json: { message: "Erro ao registrar: #{e.message}" }, status: 500
    end
  end

  def update
    begin

      user = @current_user

      if params[:image]

        delete_image(user.image) if user.image
        image_file = params[:image]
        image_path = save_image(image_file)
        image_path = request.base_url + image_path
        user.image = image_path

      end

      user.name = params[:name] if params[:name]
      user.email = params[:email] if params[:email]
      user.password = params[:password] if params[:password]

      if user.save
        log_action('Success Patch', {params: params, user: user})
        render json: { message: 'Perfil atualizado com sucesso!', user: user }, status: 200
      end

    rescue => e
      render json: { message: "Erro ao atualizar perfil: #{e.message}" }, status: 500
    end
  end

  def user_delete
    begin
      Work.where(user_id: @current_user._id).destroy_all

      delete_image(@current_user.image)

      @current_user.destroy

      render json: { message: 'Conta excluída com sucesso!' }, status: 200
    rescue => e
      render json: { message: "Erro ao excluir conta: #{e.message}" }, status: 500
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
      log_action('Sucess login', { email: email, password: password, user: user })
      render json: { message: 'Login successful!', token: token }, status: 200

    else

      log_action('Fail login', { email: email, password: password })
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

  def save_image(image_file)

    content_type = image_file.content_type.split('/').last
    filename = SecureRandom.hex + File.extname(image_file.original_filename)
    filename = filename + '.' + content_type
    filepath = Rails.root.join('public', 'storage', 'user_image', filename)

    FileUtils.mkdir_p(File.dirname(filepath))

    File.open(filepath, 'wb') do |file|
      file.write(image_file.read)
    end

    "/storage/user_image/#{filename}"
  end

end