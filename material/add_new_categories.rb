require 'open-uri'
require 'cgi'
require 'json'

# Get the subreddits from the main list so we can see what already exists
existingSubs = []
File.open('subreddit_list', 'r') do |f|
  while (line = f.gets)
    # Strip any whitespace, downcase, and add to list if not already present
    sub = line.strip.downcase
    unless existingSubs.include?(sub)
      existingSubs.push(sub)
    else
      puts "#{sub} has a duplicate"
    end
  end
end

# Get each of the categories to add. Check for duplicates and if they are already on the main list
categoriesToAdd = []
File.open("categories_to_add", 'r') do |file|
	while (line = file.gets)
	  categoryName = line.strip.downcase
	  if categoriesToAdd.include? categoryName
	  	puts "Dup! #{categoryName}"
	  elsif existingSubs.include? categoryName
	  	puts "already in main list: #{categoryName}"
	  else
	  	categoriesToAdd.push(categoryName)
		end
	end
end

MAX_ATTEMPTS = 3

# Create migration file
location = "../db/migrate/"
time = Time.now.utc.to_s.chomp("UTC").gsub(/[-: ]/, '')
file_name = "#{time}_add_categories#{time}.rb"
File.open(location + file_name, 'w') do |migration|
    # Add migration info to top of file
    migration.puts <<-START_CODE
class AddCategories#{time} < ActiveRecord::Migration
  def change
    START_CODE

    
    categoriesToAdd.each do |categoryName|
    	puts categoryName

    	# Get nsfw flag from the reddit site

			infoEndpoint = "http://www.reddit.com/r/#{categoryName}/about.json"
		  
		  categoryInfo = nil
    	MAX_ATTEMPTS.times do	|attempt|
    	  # If the category doesn't exist or there was a connection error then the result won't be json and will give an error. 
		    # Retry on failure until the attempt limit is hit, then abort.
		    begin
		    	categoryInfo = JSON.parse(open(infoEndpoint).read)
		    rescue
		    	if attempt == (MAX_ATTEMPTS - 1)
		    		abort("Unable to get data for #{categoryName}")
		    	else
		    		puts "retrying #{categoryName}"
		    	end
		    end
    	end

      nsfw = categoryInfo["data"]["over18"]

      # Add line to migration
      migration.puts <<-MIGRATE
      Category.create(name: '#{categoryName}', nsfw: #{nsfw})
      MIGRATE
    end

    # Add end tags
    migration.puts <<-END_CODE
  end
end
    END_CODE

	    # Add all categories to main list
	File.open('subreddit_list', 'a') do |mainList|
		categoriesToAdd.each do |categoryName|
			mainList.write "\n#{categoryName}"
		end
	end
end



