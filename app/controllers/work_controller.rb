# app/controllers/work_controller.rb
class WorkController < ApplicationController
  skip_before_action :authenticate_request, only: [:mall]
  def register

    title = params[:title]
    description = params[:description]
    price = params[:price]
    image_file = params[:image]

    if title.blank? || description.blank? || price.blank? || image_file.blank?
      return render json: { error: 'Todos os campos: title, description, price e image  são obrigatórios' }, status: :bad_request
    end

    begin

      image_path = save_image(image_file)
      image_path = request.base_url + image_path

      work = Work.new( user_id: @current_user._id, title: title, description: description, price: price, image: image_path )

      if work.save
        log_action('Sucess Register Work', {params: params, user: @current_user, work: work})
        render json: work, status: 200
      else
        log_action('Fail Register Work', {params: params, user: @current_user, errors: work.errors})
        render json: work.errors, status: :unprocessable_entity
      end

    rescue => e

      log_action('Super Fail Register Work', {params: params, errors: e.message})
      render json: { error: e.message }, status: :internal_server_error

    end

  end

  def get_works

    user_id = @current_user._id

    begin
      works = Work.where(user_id: user_id)
      log_action('Success Get Works', {user: @current_user, works: works})
      render json: { works: works }, status: 200
    rescue Exception => e
      log_action('Fail Get Works', {user: @current_user})
      render json: { error: e.message }, status: :internal_server_error
    end

  end

  def update

    work = Work.find_by(_id: params[:_id])
    return render json: { error: 'Trabalho não encontrado' }, status: :not_found unless work

    if work.user_id != @current_user._id
      return render json: { error: 'Permissão negada' }, status: :forbidden
    end

    if params[:image]
      delete_image(work.image)
      image_file = params[:image]
      image_path = save_image(image_file)
      image_path = request.base_url + image_path
      work.image = image_path
    end

    work.title = params[:title] if params[:title]
    work.description = params[:description] if params[:description]
    work.price = params[:price] if params[:price]

    if work.save
      log_action('Success Update Work', {params: params, user: @current_user, work: work})
      render json: work, status: 200
    else
      log_action('Fail Update Work', {params: params, user: @current_user, errors: work.errors})
      render json: work.errors, status: :unprocessable_entity
    end
  end

  def delete
    work = Work.find_by(_id: params[:_id])
    return render json: { error: 'Trabalho não encontrado' }, status: :not_found unless work

    if work.user_id != @current_user._id
      return render json: { error: 'Permissão negada' }, status: :forbidden
    end

    delete_image(work.image) if work.image.present?

    if work.destroy
      log_action('Success Delete Work', {params: params, user: @current_user, work: work})
      render json: { message: 'Trabalho deletado com sucesso' }, status: 200
    else
      log_action('Fail Delete Work', {params: params, user: @current_user, errors: work.errors})
      render json: { error: 'Erro ao deletar o trabalho' }, status: :unprocessable_entity
    end
  end

  def mall
    begin
      works = Work.all
      puts works
      render json: { works: works }, status: 200
    rescue Exception => e
      log_action('Fail mall', {Error: e, request: request})
    end
  end

  private

  def save_image(image_file)

    content_type = image_file.content_type.split('/').last
    filename = SecureRandom.hex + File.extname(image_file.original_filename)
    filename = filename + '.' + content_type
    filepath = Rails.root.join('public', 'storage', 'work_images', filename)

    FileUtils.mkdir_p(File.dirname(filepath))

    File.open(filepath, 'wb') do |file|
      file.write(image_file.read)
    end

    "/storage/work_images/#{filename}"
  end

end
