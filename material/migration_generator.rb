require 'json'

fileName = ARGV[0]

# Create migration file
time = Time.now.utc.to_s.chomp("UTC").gsub(/[-: ]/, '')
File.open("../../db/migrate/#{time}_add_images#{time}.rb", 'w') do |migration|
  # Add migration info to top of file
  migration.puts <<-START_CODE
    class AddImages#{time} < ActiveRecord::Migration
      def change

        # Map category name to id for easy access later
    categories = {}
    Category.all.each do |cat|
      categories["\#{cat.name}"] = cat
    end
  START_CODE


  # Parse each file name and add it to the migration
  File.open(fileName, 'r') do |file|
    while (line = file.gets)
      url_object = JSON.parse(line)
      imgurId = url_object["imgurId"]
      score = url_object["score"]
      subreddit = url_object["subreddit"]
      nsfw = url_object["nsfw"]
      gif = url_object["gif"]
      isAlbum = url_object["isAlbum"]

      # Add line to migration
      if isAlbum
        migration.puts <<-MIGRATE_CODE
          a = Album.create(imgurId: '#{imgurId}', reddit_score: #{score}, nsfw: #{nsfw})
          if(a.id.nil?)
            a = Album.where(imgurId: "#{imgurId}").first
          end
          c = categories["#{subreddit}"]
          unless a.categories.exists?(c)
            a.categories << c 
          end
        MIGRATE_CODE
      else
        migration.puts <<-MIGRATE_CODE
          i = Image.new(imgurId: '#{imgurId}', reddit_score: #{score}, nsfw: #{nsfw}, gif: #{gif})
          if(i.id.nil?)
            i = Image.where(imgurId: "#{imgurId}").first
          end
          c = categories["#{subreddit}"]
          unless i.categories.exists?(c)
            i.categories << c 
          end 
        MIGRATE_CODE
      end
    end
  end

  # Add end tags
  migration.puts <<-END_CODE
    end
    end
  END_CODE
end
