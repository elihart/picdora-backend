require "#{Rails.root}/material/scraper_helper.rb"
include ScraperHelper

namespace :scrape do 
 
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