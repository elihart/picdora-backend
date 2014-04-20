namespace :backup do
  desc "Backup all images to json file"
  task images: :environment do
    File.open('images_backup.json', 'w') do |f|
      
      count = 0
      startTime = Time.now
      puts "Starting image backup at #{startTime}"
      
      Image.all.limit(100).each do |image|
        categories = image.categories.pluck(:name)

        json = Jbuilder.encode do |json|
          json.imgurId image.imgurId
          json.reddit_score image.reddit_score
          json.nsfw image.nsfw
          json.gif image.gif
          json.categories categories
        end

        f.puts(json.to_s)

        count += 1
        if (count % 10000 == 0) 
          puts "#{count} : #{Time.now}" 
        end
      end

      puts "#{count} images backed up in #{Time.now - startTime} seconds"
    end
  end

  desc "Backup albums"
  task albums: :environment do
    File.open('albums_backup.json', 'w') do |f|
      Album.where.not(imgurId: nil).each do |album|
        json = Jbuilder.encode do |json|
          json.imgurId album.imgurId
          json.reddit_score album.reddit_score
          json.nsfw album.nsfw
          json.category album.category.name
        end

        f.puts(json.to_s)
      end
    end
  end

  desc "Backup categories"
  task categories: :environment do
    File.open('categories_backup.json', 'w') do |f|
      Category.all.each do |cat|
        json = Jbuilder.encode do |json|
          json.name cat.name
          json.nsfw cat.nsfw
        end

        f.puts(json.to_s)
      end
    end
  end
end
