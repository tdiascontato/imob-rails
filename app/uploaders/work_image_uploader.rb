# app/uploaders/work_image_uploader.rb
class WorkImageUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "storage/work_images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_allowlist
    %w(jpg jpeg gif png)
  end

end
