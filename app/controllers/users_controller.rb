class UsersController < ApplicationController
	# Register a login event for a given key. If the key hasn't been seen before then
	# create a new user for it. If no key is given then 400 error. We don't need to return 
	# anything on success or failure.
	def login
		key = params[:key]
		# Need a key to login
		if key.nil?
			render nothing: true, status: 400
			return
		end

		user = User.where(device_key: key).first

		# Create the user if it doesn't exist. This will be their first login.
		if user.nil?
			user = User.create(device_key: key)
		end

		# Record the login
		Login.create(user: user)
		render nothing: true, status: 200
	end
end
