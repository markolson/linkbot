require 'open-uri'
require 'hpricot'

class Gif < Linkbot::Plugin

  def self.help
    "!gif [search term] - get a gif from reddit based on the optional search term"
  end

  def self.on_message(message, matches)
    searchterm = matches[0]

    if searchterm.nil?
      reddit = "http://reddit.com/r/gifs.json"
    else
      searchterm = URI.encode(searchterm)
      reddit = "http://www.reddit.com/r/gifs/search.json?q=#{searchterm}&restrict_sr=on"
    end

    doc = ActiveSupport::JSON.decode(open(reddit).read)
    if doc["data"]["children"].length == 0
      url = "Oh poop! No gifs found..."
    else
      url = doc["data"]["children"][rand(doc["data"]["children"].length)]["data"]["url"]
    end

    # Check if it's an imgur link without an image extension
    if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
      # Fetch the imgur page and pull out the image
      doc = Hpricot(open(url).read)
      url = doc.search("img")[1]['src']
    end

    url
  end

  Linkbot::Plugin.register('gif', self, {
    :message => {:regex => /!gif(?: (.+))?/i, :handler => :on_message, :help => :help}
  })
end
