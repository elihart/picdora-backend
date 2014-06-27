DIR = "material/backup/"
IMAGE_COLUMNS = [:id, :imgurId, :nsfw, :reddit_score, :gif, :reported, :deleted, :updated_at, :created_at]
# If we try to insert all images at once it uses quite a bit of memory (> 1 gb).
# We can insert in batches to keep memory use low
IMAGE_INSERT_BATCH_SIZE = 25000

namespace :restore do
 
  desc "Restore all images from json file"
  task images: :environment do
    startTime = Time.now
    puts "Starting image restore"

    # Delete existing images and associated categories
    Image.delete_all
    # And clear their categories
    ActiveRecord::Base.connection.execute("delete from categories_images") 
    
    count = 0
    images = []
    category_data = []

    # Go through each of the files holding images. They are of the form "images_backup_#{file_number}"
    imagesFilePath = "#{DIR}images_backup_"
    imageFileCount = 0
    
    loop do
      imageFileCount += 1
      filepath = imagesFilePath + imageFileCount.to_s
      break if !File.exists? filepath
      
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
            category_data << "(#{id}, #{category_id})"
          end

          count += 1

          # If we have enough images then do the insert and clear the collected data
          if count % IMAGE_INSERT_BATCH_SIZE == 0
            insert_images(images, category_data)
            images.clear
            category_data.clear
          end

        end        
      end
    end

    # Insert the rest of the data
    insert_images(images, category_data)
    puts "#{count} images restored in #{Time.now - startTime} seconds"
  end

  # Efficiently mass insert image data into the database
  def insert_images(images_array, categories_array)
    # Import image data using ActiveRecord-Import gem. Provide model columns and array of images
    Image.import IMAGE_COLUMNS, images_array, validate: false

    #Insert the category relationships with direct sql. Sqlite limits mass inserts to 500 at a time.
    # We don't want to pad the extra space in the last batch so pass false to fill_with
    ActiveRecord::Base.transaction do    
      categories_array.in_groups_of(450, false) do |batch| 
        category_sql = "INSERT INTO categories_images (image_id, category_id) VALUES #{batch.join(", ")}"
        ActiveRecord::Base.connection.execute(category_sql) 
      end
    end
  end

  desc "Restore albums"
  task albums: :environment do
    startTime = Time.now
    puts "Starting album restore"

    # Clear all existing albums
    Album.delete_all
    # And clear their categories
    ActiveRecord::Base.connection.execute("delete from albums_categories") 

    albumColumns = [:id, :imgurId, :nsfw, :reddit_score]
    albums = []
    category_inserts = []

    filepath = "#{DIR}albums_backup"
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

    puts "#{albums.size} albums restored in #{Time.now - startTime} seconds"
  end

  desc "Restore categories"
  task categories: :environment do
    # Delete existing categories
    Category.delete_all

    count = 0
    startTime = Time.now
    puts "Starting category restore"

    categories = []

    filepath = "#{DIR}categories_backup"
    File.open(filepath, 'r') do |f|
      while (line = f.gets)
        json = JSON.parse(line)
        
        name = json["name"]
        nsfw = json["nsfw"]
        id = json["id"]
        icon = json["icon"]
        reddit_description = json["reddit_description"]
        
        categories << Category.new(id: id, icon: icon, name: name, nsfw: nsfw, reddit_description: reddit_description)
        count += 1
      end
    end

    Category.import categories, validate: false

    puts "#{count} categories restored in #{Time.now - startTime} seconds"
  end

  desc "Backup categories, images, and albums"
  task all: :environment do
    startTime = Time.now
    puts "Restoring all data"
    
    Rake::Task["restore:categories"].invoke
    Rake::Task["restore:albums"].invoke
    Rake::Task["restore:images"].invoke

    puts "Restore complete in #{Time.now - startTime} seconds"
  end
end
