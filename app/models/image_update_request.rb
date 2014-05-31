class ImageUpdateRequest < ActiveRecord::Base
	# Marks a report of an update post by a user. This could be a manual report on an inappropriate
	# image ("reported"), an automatic report of a deleted image ("deleted"), or an automatic
	# report that the gif setting is wrong ("gif"). Instead of changing the values right away on
	# update we create this request model to prevent abuse of the system, create a trail of changes
	# in case we need to reverse anything, ban updates from specific users if necessary, and preview
	# updates for correctness to prevent errors in automation. There should only be one report per
	# user per image. Each report can contain multiple flags (reported and gif, for example), but the
	# original report should be updated instead of creating a new one. This will prevent duplication
	# in case of update spamming (either purposefully by users or accidentally by automation)

	belongs_to :user
	belongs_to :image

	validates_uniqueness_of :user_id, scope: [:image_id]
	validates :user_id, presence: true
	validates :image_id, presence: true

	def self.build_request(image_id, user_id, reported, deleted, gif)
		# Create a request if one doesn't exist for this image/user combo
		request = ImageUpdateRequest.find_or_create_by(image_id: image_id, user_id: user_id)

		# Update the request. Don't change existing values unless to set them true
		request.reported |= reported
		request.deleted |= deleted
		request.gif |= gif
			
		request.save
	end
end
