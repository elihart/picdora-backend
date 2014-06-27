require "#{Rails.root}/material/scraper_helper.rb"
include ScraperHelper

namespace :scrape do 
  desc "Deprecated. Load the data of all the image scrapes into the database"
  task load_all: :environment do
    DIR_PATH = "material/post_backup_scrapes"
   
    Dir.foreach(DIR_PATH) do |filename|
      next if filename == '.' or filename == '..'

      # Skip if we've already loaded this one
      next if Scrape.exists?(key: filename)

      ActiveRecord::Base.transaction do
  
        startTime = Time.now      

        puts "Loading image data from scrape #{filename} at #{startTime}"

        File.open("#{DIR_PATH}/#{filename}", 'r') do |f|
          while (line = f.gets)
            json = JSON.parse(line)
          
            imgurId = json["imgurId"]
            nsfw = json["nsfw"]
            category = json["subreddit"]
            reddit_score = json["score"]
            gif = json["gif"]
            isAlbum = json["isAlbum"]

            item = nil
            if isAlbum
              item = Album.create(imgurId: imgurId, nsfw: nsfw, reddit_score: reddit_score)
            else
              item = Image.create(imgurId: imgurId, nsfw: nsfw, reddit_score: reddit_score, gif: gif)
            end
          
            # The item won't have been created if the imgurId is already in use. In this case we want
            # to get the original and make sure it is labeled with this category.
            if item.id.nil?
              item = isAlbum ? Album.where(imgurId: imgurId).first : Image.where(imgurId: imgurId).first
            end
            
            # Make sure the album/image has this category, but don't add it again if it already exists
            Category.where(name: category).each do |c|
              unless item.categories.exists?(c)
                item.categories << c
              end
            end 

          end

          puts "Done in #{Time.now - startTime} seconds. "        
        end

      end

      # Save the scrape so we know we've loaded it
      Scrape.create(key: filename)
    end    
  end
 
  desc "Run a scrape for images in the past week in all categories"
  task weekly: :environment do 
    startTime = Time.now  
    totalCount = 0 
    Category.find_each do |cat|
      subredditCount = 0
      GetImagesForSubreddit(cat.name, "week").each do |imageInfo|
        if TryAddImage(cat, imageInfo) 
          subredditCount += 1
        end
      end
      puts "#{subredditCount} images added to #{cat.name}"
      totalCount += subredditCount
    end 

    puts "#{totalCount} images added in #{Time.now - startTime} seconds"
  end

  desc "Initialize new categories by scraping images from all time for categories with no images"
  task new_categories: :environment do 
    startTime = Time.now  
    totalCount = 0 
    Category.find_each do |cat|
      # Skip categories that already have images
      if cat.images.count != 0
        next
      end

      puts "Getting images for #{cat.name}"

      subredditCount = 0
      imageData = GetImagesForSubreddit(cat.name, "all", "year", "month", "week")
      puts "#{imageData.size} images scraped"
      imageData.each do |imageInfo|
        if TryAddImage(cat, imageInfo) 
          subredditCount += 1
        end
      end
      puts "#{subredditCount} new images added"
      totalCount += subredditCount
    end 

    puts "#{totalCount} images added in #{Time.now - startTime} seconds"
  end

end