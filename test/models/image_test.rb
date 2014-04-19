require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test "unique_imgurId" do
  	Image.create(imgurId: "a")

  	dup = Image.new(imgurId: "a")

  	assert_not dup.valid?
  end

end
