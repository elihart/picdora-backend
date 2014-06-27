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

  desc "Set category descriptions based on reddit public description"
  task set_descriptions: :environment do
    Category.find_each do |cat|
      infoEndpoint = "http://www.reddit.com/r/#{cat.name}/about.json"
      begin
        categoryInfo = JSON.parse(open(infoEndpoint).read)
        description = categoryInfo["data"]["public_description"]
        puts "#{cat.name} : #{description}"
        cat.update(reddit_description: description)
      rescue
        puts "Error getting info for #{cat.name}"
      end
    end
  end

  desc "Add categories from the list in /material"
  task add_from_list: :environment do
    # Get each of the categories to add. Check for duplicates or if they are already in the db
    categoriesToAdd = []
    File.open("material/categories_to_add", 'r') do |file|
      while (line = file.gets)
        categoryName = line.strip.downcase
        if categoriesToAdd.include? categoryName
          puts "Dup! #{categoryName}"
        elsif Category.exists?(name: categoryName)
          puts "already in main list: #{categoryName}"
        else
          categoriesToAdd.push(categoryName)
        end
      end
    end
      
    categoriesToAdd.each do |categoryName|
      infoEndpoint = "http://www.reddit.com/r/#{categoryName}/about.json"        
      categoryInfo = nil
      begin
        categoryInfo = JSON.parse(open(infoEndpoint).read)
      rescue
        puts "Unable to get data for #{categoryName}"
        next
      end

      nsfw = categoryInfo["data"]["over18"]
      description = categoryInfo["data"]["public_description"]
      Category.create(name: categoryName, nsfw: nsfw, reddit_description: description)
    end
  end
end