require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test "imgurId_uniqueness" do
  	images(:img2).imgurId = "asdf"
  	assert_not images(:img2).valid?

  	#Should be case sensitive
  	images(:img2).imgurId = "ASDF"
  	assert images(:img2).valid?
  end

  test "imgurId_presence" do
  	images(:img1).imgurId = nil
  	assert_not images(:img1).valid?
  end

   test "score_presence" do
  	images(:img1).reddit_score = nil
  	assert_not images(:img1).valid?
  end

  test "categories" do
  	images(:img1).categories << categories(:cat1)
  	assert images(:img1).categories.size == 1
  	assert categories(:cat1).images.include?(images(:img1))

  	images(:img1).categories.delete_all
  	assert images(:img1).categories.empty?
  	assert_not categories(:cat1).images.include?(images(:img1))
  end

end
