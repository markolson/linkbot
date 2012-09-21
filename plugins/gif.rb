require 'open-uri'
require 'hpricot'

class Gif < Linkbot::Plugin

  def self.help
    "!gif [search term] - get a gif from reddit based on the optional search term"
  end
  
  create_log(:images)

  def self.on_message(message, matches)
    searchterm = matches[0]

    if searchterm.nil?
      reddit = "http://reddit.com/r/gifs.json"
    else
      searchterm = URI.encode(searchterm)
      reddit = "http://www.reddit.com/r/gifs+hifw/search.json?q=#{searchterm}&restrict_sr=on"
    end

    doc = ActiveSupport::JSON.decode(open(reddit).read)

    #reject anything with nsfw in the title
    doc = doc["data"]["children"].reject {|x| x["data"]["title"] =~ /nsfw/i || x["data"]["over_18"]}

    if doc.empty?
      url = "Oh poop! No gifs found..."
    else
      url = doc[rand(doc.length)]["data"]["url"]
    end

    # Check if it's an imgur link without an image extension
    if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
      url += ".gif"
    end

    log(:images, url)

    url
  end

  Linkbot::Plugin.register('gif', self, {
    :message => {:regex => /!gif(?: (.+))?/i, :handler => :on_message, :help => :help}
  })
end
