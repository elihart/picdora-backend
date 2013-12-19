class Category < ActiveRecord::Base
  has_many :images
  has_many :albums
end
