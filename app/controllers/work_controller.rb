# app/controllers/work_controller.rb
class WorkController < ApplicationController
  skip_before_action :authenticate_request, only: [:work_images]
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

  def user_works
    user_id = @current_user._id
    begin
      works = Work.where(user_id: user_id)
      render json: { works: works.map { |work| work.attributes.merge(image: request.base_url + work.image) } }, status: 200
    rescue Exception => e
      log_action('Fail Get Works', {user: @current_user})
      render json: { error: e.message }, status: :internal_server_error
    end

  end

  def work_images
    filename = params[:filename]
    filepath = Rails.root.join('storage', 'work_images', filename)

    if File.exist?(filepath)
      send_file(filepath, disposition: 'inline')
    else
      render plain: 'File not found', status: :not_found
    end
  end

  private

  def save_image(image_file)

    content_type = image_file.content_type.split('/').last
    filename = SecureRandom.hex + File.extname(image_file.original_filename)
    filename = filename + '.' + content_type
    filepath = Rails.root.join('storage', 'work_images', filename)

    FileUtils.mkdir_p(File.dirname(filepath))

    File.open(filepath, 'wb') do |file|
      file.write(image_file.read)
    end

    "/storage/work_images/#{filename}"
  end

end
