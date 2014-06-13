require 'test_helper'

class UserTest < ActiveSupport::TestCase
	test "device_uniqueness" do
		u1 = users(:u1)
		u2 = users(:u2)

		assert u2.valid?

		u2.device_key = u1.device_key
		assert_not u2.valid?
	end

	test "device_presence" do
		u2 = users(:u2)

		assert u2.valid?

		u2.device_key = nil
		assert_not u2.valid?
	end
end
