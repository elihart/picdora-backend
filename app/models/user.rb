class User < ActiveRecord::Base
	has_many :logins
	has_many :image_reports

	validates :device_key, presence: true
	validates :device_key, uniqueness: true
end
