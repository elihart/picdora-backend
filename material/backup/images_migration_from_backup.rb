require 'json'

File.open("images_backup.json", 'r') do |file|

  # Create migration file
  location = "../../db/migrate/"
  file_name = "#{Time.now.utc.to_s.chomp("UTC").gsub(/[-: ]/, '') }_add_images.rb"
  File.open(location + file_name, 'w') do |migration|
    # Add migration info to top of file
    migration.puts <<-START_CODE
class AddImages < ActiveRecord::Migration
  def change

    # Map category name to id for easy access later
    categories = {}
    Category.all.each do |cat|
      categories["\#{cat.name}"] = cat.id
    end
    START_CODE


    # The backup file has one object in json on each line

    while (line = file.gets)
      json = JSON.parse(line)

      attrs = []
      json.each do |key, value|
        if key == "category"
          attrs.push("category_id: categories['#{value}']")
        elsif value.instance_of? String
          attrs.push("#{key}: '#{value}'")
        else
          attrs.push("#{key}: #{value}")
        end
      end


      # Add line to migration
      migration.puts("\t\tImage.new(#{attrs.join(", ")}).save(validate: false)")
    end

    # Add end tags
    migration.puts <<-END_CODE
  end
end
    END_CODE
  end
end