require 'open-uri'
require 'hpricot'

class Gif < Linkbot::Plugin

  def self.help
    "!gif - get a random animated gif from gif.tv"
  end

  def self.on_message(message, matches)
    searchterm = matches[0]
    if searchterm.nil?
      reddit = "http://reddit.com/r/gifs.json"
    else
      reddit = "http://www.reddit.com/r/gifs/search.json?q=#{searchterm}&restrict_sr=on"
    end

    doc = ActiveSupport::JSON.decode(open(reddit).read)
    url = doc["data"]["children"][rand(doc["data"]["children"].length)]["data"]["url"]
    puts url

    # Check if it's an imgur link without an image extension
    if url =~ /http:\/\/(www\.)?imgur\.com/ && !['jpg','png','gif'].include?(url.split('.').last)
      # Fetch the imgur page and pull out the image
      doc = Hpricot(open(url).read)
      url = doc.search("img")[1]['src']

      if ::Util.wallpaper?(url)
        url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
      end
    end

    url
  end

  Linkbot::Plugin.register('gif', self, {
    :message => {:regex => /!gif(?: (.+))?/i, :handler => :on_message, :help => :help}
  })
end
