require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test "name_presence" do
  	c = Category.new
   assert_not c.valid?

   c.name = "test"
   assert c.valid?
  end

  test "name_uniqueness" do
  	existingName = categories(:cat1).name.downcase
  	c = Category.new(name: existingName)
  	assert_not c.valid?

 	# Should be case insensitive
  	existingName.upcase!
  	c.name = existingName
  	assert_not c.valid?

  	c.name = "lkjwoeiualdkalsdaslnflweuaoiudfakjsdf"
  	assert c.valid?
  end
end
