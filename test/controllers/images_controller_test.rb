require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
 test "update" do
 		user_id = users(:u1)
 		key = users(:u1).device_key
  	image_id = images(:img1).id

  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 0

  	put(:update, {})
  	assert_response 400

  	put(:update, {id: image_id})
  	assert_response 400

  	put(:update, {key: key})
  	assert_response 400

  	# Test non existent user
  	put(:update, {id: image_id, key: "weoiruq29358qwh"})
  	assert_response 404

  	# Test real user but not updating anything
  	put(:update, {id: image_id, key: key})
  	assert_response 200

  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1

  	request = ImageUpdateRequest.where(user_id: user_id, image_id: image_id).first
  	assert !request.reported && !request.deleted && !request.gif

  	# Test real user updating two things
  	put(:update, {id: image_id, key: key, reported: true, gif: true})
  	assert_response 200

  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1

  	request = ImageUpdateRequest.where(user_id: user_id, image_id: image_id).first
  	assert request.reported && !request.deleted && request.gif

  	# Test changing deleted
  	put(:update, {id: image_id, key: key, reported: false, gif: false, deleted: true})
  	assert_response 200

  	assert ImageUpdateRequest.where(user_id: user_id, image_id: image_id).count == 1

  	request = ImageUpdateRequest.where(user_id: user_id, image_id: image_id).first
  	assert request.reported && request.deleted && request.gif



 end
end
