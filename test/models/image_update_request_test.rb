require 'test_helper'

class ImageReportTest < ActiveSupport::TestCase
  
  test "build request" do
  	user_id = users(:u1).id
  	image_id = images(:img1).id

  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 0

  	ImageUpdateRequest.build_request(user_id, image_id, false, false, false)
  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1

  	# Test uniqueness of ids
  	request = ImageUpdateRequest.create(user_id, image_id, false, false, false)
  	assert_not request.valid?

  	# Test initial values
  	request = ImageUpdateRequest.where(user_id: user_id, image_id: user_id).first
  	assert !request.reported && !request.deleted && !request.gif

  	# Try updating existing request
  	ImageUpdateRequest.build_request(user_id, image_id, true, false, false)

  	# Count should still be one, modifying existing request instead of creating new one
  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1

  	# Verify new values
  	request = ImageUpdateRequest.where(user_id: user_id, image_id: user_id).first
  	assert request.reported && !request.deleted && !request.gif

  	# Try another update
  	ImageUpdateRequest.build_request(user_id, image_id, false, false, true)
  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1
  	request = ImageUpdateRequest.where(user_id: user_id, image_id: user_id).first
  	assert request.reported && !request.deleted && request.gif

  	# Try another update
  	ImageUpdateRequest.build_request(user_id, image_id, false, true, true)
  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1
  	request = ImageUpdateRequest.where(user_id: user_id, image_id: user_id).first
  	assert request.reported && request.deleted && request.gif

	end
end
