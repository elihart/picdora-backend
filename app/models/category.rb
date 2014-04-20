class Category < ActiveRecord::Base
  has_and_belongs_to_many :images
  has_and_belongs_to_many :albums

  validates :name, uniqueness: {case_sensitive: false}
  validates :name, presence: true
end
