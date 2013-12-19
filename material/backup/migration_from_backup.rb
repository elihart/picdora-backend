require 'json'

# Create a migration file for adding Albums from the json in albums_backup.json

# type should be the plural version (categories) and model the singular (category). This is easier than trying to guess the pluralized form
type = ARGV[0].downcase
model = ARGV[1].downcase

File.open("#{type}_backup.json", 'r') do |file|

  # Create migration file
  location = "../../db/migrate/"
  file_name = "#{Time.now.utc.to_s.chomp("UTC").gsub(/[-: ]/, '') }_add_#{type}.rb"
  File.open(location + file_name, 'w') do |migration|
    # Add migration info to top of file
    migration.puts <<-START_CODE
class Add#{type.capitalize} < ActiveRecord::Migration
  def change
    START_CODE


    # The backup file has one category object in json on each line

    while (line = file.gets)
      json = JSON.parse(line)

      attrs = []
      json.each do |key, value|
        if value.instance_of? String
          attrs.push("#{key}: '#{value}'")
        else
          attrs.push("#{key}: #{value}")
        end
      end


      # Add line to migration
      migration.puts("\t\t#{model.capitalize}.new(#{attrs.join(", ")}).save(validate: false)")
    end


    # Add end tags
    migration.puts <<-END_CODE
  end
end
    END_CODE
  end
end