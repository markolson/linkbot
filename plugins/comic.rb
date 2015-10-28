require 'active_support'

class Comic < Linkbot::Plugin

  def initialize
    register :regex => Regexp.new('(?:!comic|!fffffffuuuuuuuuuuuu)(?: (\d+))?')
    help "!comic - return a random fffffffuuuuuuuuuuuu comic"
  end

  def on_message(message, matches)
    times = matches[0] || "1"
    times = times.to_i
    messages = []

    1.upto(times) do

      # Brute force this mother
      subreddit = "http://reddit.com/r/fffffffuuuuuuuuuuuu.json"

      Linkbot.log.debug subreddit
      doc = ActiveSupport::JSON.decode(open(subreddit, "Cookie" => "reddit_session=8390507%2C2011-03-22T07%3A06%3A44%2C2516dcc69a22ad297b9900cbde147b365203bbbb").read)

      url = doc["data"]["children"][rand(doc["data"]["children"].length)]["data"]["url"]

      # Check if it's an imgur link without an image extension
      if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
        url += '.jpg'
      end

      messages << url
    end
    return messages.join("\n")
  end

end
