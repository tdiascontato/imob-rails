class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :password, type: String
  # field :session_token, type: String
end
