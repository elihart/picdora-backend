class Scrape < ActiveRecord::Base
	validates :key, uniqueness: true
  validates :key,  presence: true
end
