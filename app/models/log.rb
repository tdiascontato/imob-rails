class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'Log'

  field :action, type: String
  field :function, type: String
  field :body, type: Hash
  field :path, type: String
  field :user, type: Hash

  belongs_to :user, optional: true
end
