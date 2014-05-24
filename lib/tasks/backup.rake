namespace :backup do
  desc "Backup all images to json file"
  task images: :environment do
    File.open('images_backup.json', 'w') do |f|      
      count = 0
      startTime = Time.now
      puts "Starting image backup at #{startTime}"
      
      Image.includes(:categories).find_each do |image|
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

        f.puts(json.to_s)

        count += 1
        if (count % 10000 == 0) 
          puts "#{count} : #{Time.now - startTime}" 
        end
      end

      puts "#{count} images backed up in #{Time.now - startTime} seconds"
    end
  end

  desc "Backup albums"
  task albums: :environment do
    File.open('albums_backup.json', 'w') do |f|
      count = 0
      startTime = Time.now
      puts "Starting album backup at #{startTime}"

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
    File.open('categories_backup.json', 'w') do |f|
      Category.all.each do |cat|
        json = Jbuilder.encode do |json|
          json.id cat.id
          json.name cat.name
          json.nsfw cat.nsfw
          json.icon cat.icon
        end

        f.puts(json.to_s)
      end
    end
  end
end
