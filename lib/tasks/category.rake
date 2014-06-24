require 'open-uri'

namespace :category do
  desc "update category icons based on the most popular images"
  task set_icons: :environment do
    # Can change this to go through all categories or just those with no icon yet
    #Category.find_each do |cat|
    Category.where(icon: nil).each do |cat|
    	# Get top images for each category. Offset them slightyly; sometimes the first images are weird...
    	# Get a batch of several because the first one might have been deleted. Test the connection to
    	# each one and don't use it if we can't access it.
     cat.images.where(reported: false, deleted: false, nsfw: cat.nsfw).order(reddit_score: :desc).offset(10).limit(20).each do |img|
     	# Test that the image isn't deleted
     	begin
     		# if the url opens successfully then we can save it and go onto the next category.
     		open("http://i.imgur.com/#{img.imgurId}")
     		cat.update(icon: img.imgurId)
     		break
      rescue OpenURI::HTTPError => ex
     		# Error opening url if image doesn't exist anymore. Try the next one
     		puts "Deleted image for #{cat.name}"
     	end
     end     
    end

  end
end