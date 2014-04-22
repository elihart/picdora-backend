DIR = "material/backup/"

namespace :restore do
 
  desc "Restore all images from json file"
  task images: :environment do
    count = 0
    startTime = Time.now
    puts "Starting image restore at #{startTime}"
    filepath = "#{DIR}images_backup.json"
    File.open(filepath, 'r') do |f|
      while (line = f.gets)
        json = JSON.parse(line)
      
        imgurId = json["imgurId"]
        nsfw = json["nsfw"]
        categories = json["categories"]
        reddit_score = json["reddit_score"]
        gif = json["gif"]
      
        i = Image.create(imgurId: imgurId, nsfw: nsfw, reddit_score: reddit_score, gif: gif)
        if(i.id.nil?)
          i = Image.where(imgurId: imgurId).first
        end
        
        Category.where(name: categories).each do |c|
          unless i.categories.exists?(c)
            i.categories << c
          end
        end 

        count += 1
        if (count % 10000 == 0) 
          puts "#{count} : #{Time.now}" 
        end
      end

      puts "#{count} images restored in #{Time.now - startTime} seconds"
    end
  end

  desc "Restore albums"
  task albums: :environment do
    count = 0
    startTime = Time.now
    puts "Starting album restore at #{startTime}"

    filepath = "#{DIR}albums_backup.json"
    File.open(filepath, 'r') do |f|
      while (line = f.gets)
        json = JSON.parse(line)
       
        imgurId = json["imgurId"]
        nsfw = json["nsfw"]
        categories = json["categories"]
        reddit_score = json["reddit_score"]

        a = Album.new(imgurId: imgurId, nsfw: nsfw, reddit_score: reddit_score)
        a.save(validate: false)
        a.categories= Category.where(name: categories)
      
        count += 1
        if (count % 10000 == 0) 
         puts "#{count} : #{Time.now}" 
        end
      end
    end

    puts "#{count} albums restored in #{Time.now - startTime} seconds"
  end

  desc "Restore categories"
  task categories: :environment do
    count = 0
    startTime = Time.now
    puts "Starting category restore at #{startTime}"

    filepath = "#{DIR}categories_backup.json"
    File.open(filepath, 'r') do |f|
      while (line = f.gets)
        json = JSON.parse(line)
        name = json["name"]
        nsfw = json["nsfw"]
        Category.create(name: name, nsfw: nsfw)
        count += 1
      end
    end

    puts "#{count} categories restored in #{Time.now - startTime} seconds"
  end
end
