require 'test_helper'

class ImageReportTest < ActiveSupport::TestCase
  
  test "validations" do
  	user_id = users(:u1).id
  	user_id_2 = users(:u2).id
  	image_id = images(:img1).id

  	# Test no user
  	request = ImageUpdateRequest.new(image_id: image_id)
  	assert_not request.valid?

  	# Test no image
  	request = ImageUpdateRequest.new(user_id: user_id)
  	assert_not request.valid?

  	request = ImageUpdateRequest.new(user_id: user_id, image_id: image_id)
  	assert request.valid?
  	request.save

  	# Test uniqueness of user/image combo
  	request = ImageUpdateRequest.new(user_id: user_id, image_id: image_id)
  	assert_not request.valid?

  	request = ImageUpdateRequest.new(user_id: user_id_2, image_id: image_id)
  	assert request.valid?




  end

  test "build request" do
  	user_id = users(:u1).id
  	image_id = images(:img1).id

  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 0

  	ImageUpdateRequest.build_request(image_id, user_id, false, false, false)
  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1

  	# Test initial values
  	request = ImageUpdateRequest.where(user_id: user_id, image_id: image_id).first
  	assert !request.reported && !request.deleted && !request.gif

  	# Try updating existing request
  	ImageUpdateRequest.build_request(image_id, user_id, true, false, false)

  	# Count should still be one, modifying existing request instead of creating new one
  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1

  	# Verify new values
  	request = ImageUpdateRequest.where(user_id: user_id, image_id: image_id).first
  	assert request.reported && !request.deleted && !request.gif

  	# Try another update
  	ImageUpdateRequest.build_request(image_id, user_id, false, false, true)
  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1
  	request = ImageUpdateRequest.where(user_id: user_id, image_id: image_id).first
  	assert request.reported && !request.deleted && request.gif

  	# Try another update
  	ImageUpdateRequest.build_request(image_id, user_id, false, true, true)
  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1
  	request = ImageUpdateRequest.where(user_id: user_id, image_id: image_id).first
  	assert request.reported && request.deleted && request.gif

    # Try nil values. Values shouldn't change
    ImageUpdateRequest.build_request(image_id, user_id, nil, nil, nil)
    request = ImageUpdateRequest.where(user_id: user_id, image_id: image_id).first
    assert request.reported && request.deleted && request.gif

	end
end
