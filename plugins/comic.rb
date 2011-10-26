require 'active_support'

class Comic < Linkbot::Plugin
  Linkbot::Plugin.register('comic', self,
    {
      :message => {:regex => Regexp.new('(?:!comic|!fffffffuuuuuuuuuuuu)(?: (\d+))?'), :handler => :on_message, :help => :help},
    }
  )

  def self.on_message(message, matches)
    times = matches[0] || "1"
    times = times.to_i
    messages = []

    1.upto(times) do

      # Brute force this mother
      subreddit = "http://reddit.com/r/fffffffuuuuuuuuuuuu.json"

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
    "!comic - return a random fffffffuuuuuuuuuuuu comic"
  end
end
