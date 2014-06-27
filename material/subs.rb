require 'open-uri'
require 'cgi'
require 'json'

after = ''
count = 0
begin
	endpoint = "http://www.reddit.com/subreddits/popular.json?limit=100&after=#{after}"
  result = JSON.parse(open(endpoint).read)
  data = result["data"]
  after = data["after"]
  
  data["children"].each do |child|
  	count += 1
  	after = nil if count > 100
  	childData = child["data"]
  	subscribers = childData["subscribers"]
  	puts "#{childData["display_name"]} : #{subscribers}"
  end
rescue
  puts "Error"
  break
end while (after && !after.empty?)