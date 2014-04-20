class Category < ActiveRecord::Base
  has_and_belongs_to_many :images, uniq: true
  has_and_belongs_to_many :albums, uniq: true

  validates :name, uniqueness: {case_sensitive: false}
  validates :name, presence: true
end
