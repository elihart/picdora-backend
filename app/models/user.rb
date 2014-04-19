class User < ActiveRecord::Base
	has_many :logins
end
