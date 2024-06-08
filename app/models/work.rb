class Work
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'Work'

  field :user_id, type: String
  field :title, type: String
  field :description, type: String
  field :image, type: String
  field :price, type: String

  belongs_to :user, optional: true

  validates :title, :description, :price, :image, presence: true
end
