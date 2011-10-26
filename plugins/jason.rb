require 'active_support'

class Jason < Linkbot::Plugin
  Linkbot::Plugin.register('jason', self,
    {
      :message => {:regex => Regexp.new('(?:!randomlink|!jason)(?: (\d+))?'), :handler => :on_message, :help => :help},
      :"direct-message" => {:regex => Regexp.new('(?:!randomlink|!jason)(?: (\d+))?'), :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches) 
    times = matches[0]
        reddits = {
          "/r/pics/" => 10,
          "/r/comics/" => 10,
          "/r/wallpaper/" => 10,
          "/r/gonewild/" => 2,
          "/r/funny/" => 10,
          "/r/fffffffuuuuuuuuuuuu/" => 10,
          "/r/reddit.com/" => 10,
        	"/r/WTF/" => 10,
        	"/r/bestof/" => 10,
        	"/r/videos/" => 10,
        	"/r/aww" => 10,
        }
 
        # Build out a weighted range
        total_value = reddits.values.reduce(:+)
        last_end = 0.0
        
        reddits.each do |k,v|
          reddits[k] = [last_end, last_end + (v.to_f / total_value)*100]
          last_end += (v.to_f / total_value) * 100
        end
        
        times = times ? times.to_i : 1
        times = times <= 5 ? times : 5 
 
        messages = []
              
        1.upto(times) do
          
          # Brute force this mother
          subreddit = nil
          val = rand(100000)/1000.0
          reddits.each {|k,v|
            if val >= v[0] && val <= v[1]
              subreddit = "http://reddit.com#{k}.json"
              break
            end
          }
                  
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
        return messages.join("\n")
  end
  
  def self.help
    "!randomlink - return a random link"
  end
end
