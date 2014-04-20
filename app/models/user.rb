class User < ActiveRecord::Base
	has_many :logins

	validates :device_key, presence: true
	validates :device_key, uniqueness: true
end
