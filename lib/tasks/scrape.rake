namespace :scrape do
 
  desc "Load the data of all the image scrapes into the database"
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
          
            if item.id.nil?
              item = isAlbum ? Album.where(imgurId: imgurId).first : Image.where(imgurId: imgurId).first
            end
            
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

end