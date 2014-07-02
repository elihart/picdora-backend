require 'open-uri'
require 'cgi'
require 'json'

def viability(subreddit)
	totalLinks = 0
	imgurLinks = 0
	after = ''
  begin
    # Get the first batch of links      
    result = GetRedditLinks(buildUrl(subreddit, "all", after))
    links = result[:links]
    after = result[:after]

    # Process links
    links.each do |link|
      totalLinks += 1
      if link.match("imgur.com")
      	imgurLinks += 1
      end
    end

    # Must wait between each query
    sleep 1
  end while (after && !after.empty?)

	return "#{imgurLinks} #{imgurLinks.to_f / totalLinks}"
end

def GetRedditLinks(url)
  links = []

  # Run reddit query and parse into json object
  while true
    begin
      results = JSON.parse(open(url).read)
      break
    rescue
      puts "Error reaching reddit. Trying again..."
      sleep 3
    end
  end

  # Record results
  results["data"]["children"].each do |result|
    links.push(result["data"]["url"])
  end

  # Add 'After' attribute to return
  return {links: links, after: results["data"]["after"]}
end

def buildUrl(subreddit, time, after)
	"http://www.reddit.com/r/#{subreddit}/top.json?sort=top&limit=100&t=#{time}&after=#{after}"
end

after = ''
count = 0
begin
	endpoint = "http://www.reddit.com/subreddits/popular.json?limit=100&after=#{after}"
  result = JSON.parse(open(endpoint).read)
  data = result["data"]
  after = data["after"]
  
  data["children"].each do |child|
  	count += 1
  	after = nil if count > 10000
  	childData = child["data"]
  	name = childData["display_name"]
  	subscribers = childData["subscribers"]
  	puts "#{name} #{viability(name)}"
  end
# rescue
#   puts "Error"
#   break
end while (after && !after.empty?)

