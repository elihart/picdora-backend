require 'json'

File.open("albums_backup.json", 'r') do |file|

  # Create migration file
  location = "../../db/migrate/"
  file_name = "#{Time.now.utc.to_s.chomp("UTC").gsub(/[-: ]/, '') }_add_albums.rb"
  File.open(location + file_name, 'w') do |migration|
    # Add migration info to top of file
    migration.puts <<-START_CODE
class AddAlbums < ActiveRecord::Migration
  def change

    # Map category name to id for easy access later
    categories = {}
    Category.all.each do |cat|
      categories["\#{cat.name}"] = cat
    end
    START_CODE



    # The backup file has one object in json on each line

    while (line = file.gets)
      json = JSON.parse(line)

      cat = nil
      imgurId = nil
      attrs = []
      json.each do |key, value|
        if key == "category"
         cat = value
        elsif value.instance_of? String
          attrs.push("#{key}: '#{value}'")
        else
          attrs.push("#{key}: #{value}")
        end

        if key == "imgurId"
         imgurId = value
       end
      end


      # Add line to migration
      migration.puts <<-CREATE
    a = Album.create(#{attrs.join(", ")})
    if(a.id.nil?)
      a = Album.where(imgurId: "#{imgurId}").first
    end
    c = categories["#{cat}"]
    unless a.categories.exists?(c)
      a.categories << c 
    end 
      CREATE
    end

    # Add end tags
    migration.puts <<-END_CODE
  end
end
    END_CODE
  end
end