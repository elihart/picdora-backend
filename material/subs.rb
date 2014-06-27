require 'open-uri'
require 'cgi'
require 'json'

after = ''

endpoint = "http://www.reddit.com/subreddits/popular.json?limit=100&after=#{after}"
begin
  result = JSON.parse(open(endpoint).read)
  data = result["data"]
  after = data["after"]
  
  data["children"].each do |child|
  	childData = child["data"]
  	puts childData["display_name"]
  end
rescue
  puts "Error"
  break
end while (after && !after.empty?)