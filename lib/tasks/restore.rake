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
      
        i = Image.new(imgurId: imgurId, nsfw: nsfw, reddit_score: reddit_score, gif: gif)
        i.save(validate: false)
        i.categories= Category.where(name: categories)

        count += 1
        if (count % 10000 == 0) 
          puts "#{count} : #{Time.now}" 
        end
      end

      puts "#{count} images restored in #{Time.now - startTime} seconds"
    end
  end

  # desc "Restore albums"
  # task albums: :environment do
  #   count = 0
  #   startTime = Time.now
  #   puts "Starting album restore at #{startTime}"

  #   filepath = "#{DIR}albums_backup.json"
  #   File.open(filepath, 'r') do |f|
  #     while (line = f.gets)
  #       json = JSON.parse(line)
       
  #       imgurId = json["imgurId"]
  #       nsfw = json["nsfw"]
  #       categories = json["categories"]
  #       reddit_score = json["reddit_score"]

  #       a = Album.new(imgurId: imgurId, nsfw: nsfw, reddit_score: reddit_score)
  #       a.save(validate: false)
  #       a.categories= Category.where(name: categories)
      
  #       count += 1
  #       if (count % 5000 == 0) 
  #        puts "#{count} : #{Time.now - startTime} elapsed" 
  #       end
  #     end
  #   end

  #   puts "#{count} albums restored in #{Time.now - startTime} seconds"
  # end

  desc "Restore albums"
  task albums: :environment do
    # Clear all existing albums
    Album.delete_all
    # And clear their categories
    ActiveRecord::Base.connection.execute("delete from albums_categories") 

    albumColumns = [:id, :imgurId, :nsfw, :reddit_score]
    albums = []
    category_inserts = []

    filepath = "#{DIR}albums_backup.json"
    File.open(filepath, 'r') do |f|
      while (line = f.gets)
        json = JSON.parse(line)
       
        id = json["id"]
        imgurId = json["imgurId"]
        nsfw = json["nsfw"]
        categories = json["categories"]
        reddit_score = json["reddit_score"]

        albums << [id, imgurId, nsfw, reddit_score]

        categories.each do |category_id|
          category_inserts << "(#{id}, #{category_id})"
        end
      end
    end

    Album.import albumColumns, albums, validate: false

    #Insert the category relationships with direct sql. Sqlite limits mass inserts to 500 at a time.
    # We don't want to pad the extra space in the last batch so pass false to fill_with
    ActiveRecord::Base.transaction do    
      category_inserts.in_groups_of(450, false) do |batch| 
        category_sql = "INSERT INTO albums_categories (album_id, category_id) VALUES #{batch.join(", ")}"
        ActiveRecord::Base.connection.execute(category_sql) 
      end
    end

    puts "#{albums.size} albums restored"
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
