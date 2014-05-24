DIR = "material/backup/"

namespace :restore do
 
  desc "Restore all images from json file"
  task images: :environment do
    # Delete existing images and associated categories
    Image.delete_all
    # And clear their categories
    ActiveRecord::Base.connection.execute("delete from categories_images") 

    imageColumns = [:id, :imgurId, :nsfw, :reddit_score, :gif, :reported, :deleted, :updated_at, :created_at]
    images = []
    category_inserts = []

    filepath = "#{DIR}images_backup.json"
    File.open(filepath, 'r') do |f|
      while (line = f.gets)
        json = JSON.parse(line)
      
        id = json["id"]
        imgurId = json["imgurId"]
        nsfw = json["nsfw"]
        categories = json["categories"]
        reddit_score = json["reddit_score"]
        gif = json["gif"]
        reported = json["reported"]
        deleted = json["deleted"]
        updated_at = json["updated_at"]
        created_at = json["created_at"]


        images << [id, imgurId, nsfw, reddit_score, gif, reported, deleted, updated_at, created_at]
        
        categories.each do |category_id|
          category_inserts << "(#{id}, #{category_id})"
        end
      end
    end

    Image.import imageColumns, images, validate: false

    #Insert the category relationships with direct sql. Sqlite limits mass inserts to 500 at a time.
    # We don't want to pad the extra space in the last batch so pass false to fill_with
    ActiveRecord::Base.transaction do    
      category_inserts.in_groups_of(450, false) do |batch| 
        category_sql = "INSERT INTO categories_images (image_id, category_id) VALUES #{batch.join(", ")}"
        ActiveRecord::Base.connection.execute(category_sql) 
      end
    end

    puts "#{images.size} images restored"
  end

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
    # Delete existing categories
    Category.delete_all

    count = 0
    startTime = Time.now
    puts "Starting category restore at #{startTime}"

    categories = []

    filepath = "#{DIR}categories_backup.json"
    File.open(filepath, 'r') do |f|
      while (line = f.gets)
        json = JSON.parse(line)
        
        name = json["name"]
        nsfw = json["nsfw"]
        id = json["id"]
        icon = json["icon"]
        
        categories << Category.new(id: id, icon: icon, name: name, nsfw: nsfw)
        count += 1
      end
    end

    Category.import categories, validate: false

    puts "#{count} categories restored in #{Time.now - startTime} seconds"
  end
end
