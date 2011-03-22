require 'active_support'

class Jason < Linkbot::Plugin
  def self.regex
    Regexp.new('(?:!randomlink|!jason)(?: (\d+))?')
  end
  Linkbot::Plugin.register('jason', self.regex, self)
  
  def self.on_message(user, message, matches) 
    times = matches[0]
        reddits = [
          "/r/pics/",
          "/r/comics/",
          "/r/wallpaper/",
          "/r/gonewild/",
          "/r/funny/",
          "/r/fffffffuuuuuuuuuuuu/",
          "/r/reddit.com/",
        	"/r/WTF/",
        	"/r/bestof/",
        	"/r/videos/",
        	"/r/aww",
        ]
        times = times ? times.to_i : 1
        times = times <= 5 ? times : 5 
 
        messages = []
        
        1.upto(times) do
          subreddit = "http://reddit.com#{reddits[rand(reddits.length)]}.json"
          puts subreddit
          doc = ActiveSupport::JSON.decode(open(subreddit, "Cookie" => "reddit_session=8390507%2C2011-03-22T07%3A06%3A44%2C2516dcc69a22ad297b9900cbde147b365203bbbb").read)
          
          url = doc["data"]["children"][rand(doc["data"]["children"].length)]["data"]["url"]
          
          # Check if it's an imgur link without an image extension
          if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
            # Fetch the imgur page and pull out the image
            doc = Hpricot(open(url).read)
            url = doc.search("img")[1]['src']
          end
          
          messages << url
        end
        return messages
  end
  
  def self.help
    "!randomlink - return a random link"
  end
end