require 'jwt'

class JsonWebToken
  SECRET_KEY=ENV['SECRET_KEY']

  def self.encode(payload, exp = 36.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new body
  rescue
    nil
  end
end
