require 'test_helper'

class AlbumTest < ActiveSupport::TestCase
  test "imgurId_uniqueness" do
  	a1 = albums(:album1)
  	a2 = albums(:album2)
  	assert a2.valid?

  	a2.imgurId = a1.imgurId
  	assert_not a2.valid?

	#Should be case sensitive
  	a2.imgurId.upcase!
  	assert a2.valid?
  end

  test "imgurId_presence" do
  	a1 = albums(:album1)
  	assert a1.valid?

  	a1.imgurId = nil
  	assert_not a1.valid?
  end

   test "score_presence" do
  	a1 = albums(:album1)
  	assert a1.valid?

  	a1.reddit_score = nil
  	assert_not a1.valid?
  end

  test "categories" do
  	c = categories(:cat1)
  	a = albums(:album1)

  	a.categories << c
  	assert a.categories.size == 1
  	assert c.albums.include?(a)

  	a.categories.delete_all
  	assert a.categories.empty?
  	assert_not c.albums.include?(a)
  end
end
