namespace :scrape do
 
  desc "Load the data of all the image scrapes into the database"
  task load_all: :environment do
    DIR_PATH = "material/post_backup_scrapes"
   
    Dir.foreach(DIR_PATH) do |item|
      next if item == '.' or item == '..'

      # Skip if we've already loaded this one
      next if Scrape.exists?(key: item)
  
      startTime = Time.now      
      added = 0
      dups = 0
      dupButCatAdded = 0
      count = 0

      puts "Loading image data from scrape #{item} at #{startTime}"

      File.open("#{DIR_PATH}/#{item}", 'r') do |f|
        while (line = f.gets)
          json = JSON.parse(line)
        
          imgurId = json["imgurId"]
          nsfw = json["nsfw"]
          category = json["subreddit"]
          reddit_score = json["score"]
          gif = json["gif"]
          isAlbum = json["isAlbum"]

          next unless isAlbum

          item = nil
          if isAlbum
            item = Album.create(imgurId: imgurId, nsfw: nsfw, reddit_score: reddit_score)
          else
            item = Image.create(imgurId: imgurId, nsfw: nsfw, reddit_score: reddit_score, gif: gif)
          end
        
          dup = item.id.nil?
          if dup
            item = isAlbum ? Album.where(imgurId: imgurId).first : Image.where(imgurId: imgurId).first
            dups += 1
          else
            added += 1
          end
          
          Category.where(name: category).each do |c|
            unless item.categories.exists?(c)
              item.categories << c
              if dup
                dupButCatAdded += 1
              end
            end
          end 
          
          count += 1
          if (count % 2000 == 0) 
            puts "#{count} : #{Time.now}" 
          end
        end

        puts "#{added} images added in #{Time.now - startTime} seconds. #{dups} duplicates caught and ignored. #{dupButCatAdded} duplicates had categories added"
        
        # Save the scrape so we know we've loaded it
        Scrape.create(key: item)
      end
    end
  end

end