class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    begin
      decoded_token = JsonWebToken.decode(token)
      @current_user = User.find_by(_id: decoded_token[:user_id], token: token)

      unless @current_user
        render json: { message: 'Token inválido ou usuário não autenticado' }, status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
      render json: { message: 'Token inválido!' }, status: :unauthorized
    end
  end

  def log_action(action, body)
    Log.create(action: action, function: action_name, path: request.path, body: body.to_json, user_id: @current_user._id)
  rescue => e
    Rails.logger.error("Failed to log action: #{e.message}")
  end

end
