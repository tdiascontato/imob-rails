require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :password_digest, type: String

  store_in collection: "User"

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  def password=(new_password)
    self.password_digest = BCrypt::Password.create(new_password)
  end

  def authenticate(password)
    BCrypt::Password.new(self.password_digest) == password
  end
end
