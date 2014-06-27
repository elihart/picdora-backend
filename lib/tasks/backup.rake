namespace :backup do
  desc "Backup all images to json file"
  task images: :environment do
    # Base file name for the backup files
    FILE_NAME = "images_backup"
    # To limit file size we'll split the backups up into multiple files. Limit each file 
    # to a maximum of this many images.
    IMAGES_PER_FILE = 100000;

    count = 0
    file_number = 0
    destFile = nil
    startTime = Time.now
    puts "Starting image backup"      
    
    Image.includes(:categories).find_each do |image|
      # Open a new file when the current one is full
      if count % IMAGES_PER_FILE == 0
        destFile.close unless destFile.nil?
        file_number += 1
        destFile = File.open("#{FILE_NAME}_#{file_number}", 'w') 
      end

      category_ids = []
      image.categories.each do |c|
        category_ids << c.id
      end

      json = Jbuilder.encode do |json|
        json.id image.id
        json.deleted image.deleted
        json.reported image.reported
        json.imgurId image.imgurId
        json.reddit_score image.reddit_score
        json.nsfw image.nsfw
        json.gif image.gif
        json.created_at image.created_at
        json.updated_at image.updated_at
        json.categories category_ids
      end

      destFile.puts(json.to_s)

      count += 1
      if (count % 50000 == 0) 
        puts "#{count} : #{Time.now - startTime}" 
      end
    end

    destFile.close
    puts "#{count} images backed up in #{Time.now - startTime} seconds"
  end

  desc "Backup albums"
  task albums: :environment do
    File.open('albums_backup', 'w') do |f|
      count = 0
      startTime = Time.now
      puts "Starting album backup"

      Album.includes(:categories).find_each do |album|
        category_ids = []
        album.categories.each do |c|
          category_ids << c.id
        end

        # TODO: If we ever start using albums we should also back up their deleted status and timestamps
        json = Jbuilder.encode do |json|
          json.id album.id
          json.imgurId album.imgurId
          json.reddit_score album.reddit_score
          json.nsfw album.nsfw
          json.categories category_ids
        end

        f.puts(json.to_s)

        count += 1
        if (count % 10000 == 0) 
          puts "#{count} : #{Time.now - startTime}" 
        end
      end

      puts "#{count} albums backed up in #{Time.now - startTime} seconds"
    end
  end

  desc "Backup categories"
  task categories: :environment do
    startTime = Time.now
    puts "Backing up categories"
    File.open('categories_backup', 'w') do |f|
      Category.all.each do |cat|
        json = Jbuilder.encode do |json|
          json.id cat.id
          json.name cat.name
          json.nsfw cat.nsfw
          json.icon cat.icon
          json.reddit_description cat.reddit_description
        end

        f.puts(json.to_s)
      end
    end

    puts "Backed up #{Category.all.size} categories in #{Time.now - startTime} seconds"
  end

  desc "Backup categories, images, and albums"
  task all: :environment do
    startTime = Time.now
    puts "Backing up all data"
    
    Rake::Task["backup:categories"].invoke
    Rake::Task["backup:albums"].invoke
    Rake::Task["backup:images"].invoke

    puts "Backup complete in #{Time.now - startTime} seconds"
  end
end
