require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :password

  field :email, type: String
  field :password_digest, type: String
  field :token, type: String

  store_in collection: "User"

  # has_many :works, class_name: 'Work'

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  before_save :encrypt_password

  def encrypt_password
    if password.present?
      self.password_digest = BCrypt::Password.create(password)
    end
  end

  def authenticate(password)
    BCrypt::Password.new(self.password_digest) == password
  end
end
