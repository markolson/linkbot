require 'open-uri'
require 'image_size'
require 'uri'
require 'cgi'

class Image < Linkbot::Plugin
  
  Linkbot::Plugin.register('image', self,
    {
      :message => {:regex => /!image(?: (.+))?/, :handler => :on_message, :help => :help}
    }
  )
  
  create_log(:images)
  
  def self.on_message(message, matches) 
    searchterm = matches[0]
    color = nil
    if searchterm.nil?
      searchterm = message_history(message)[1]['body']
      if searchterm == "!image"
        doc = Hpricot(open("http://www.randomword.net").read)
        searchterm = doc.search("#word h2").text.strip
      end
    end
    if searchterm =~ /$\(\w+\) ^/
      parts = searchterm.split(" ")
      color = parts.shift
      searchterm = parts.join(" ")
    end

    begin
      # Give google 2 seconds to respond (and for us to parse it!)
      Timeout::timeout(2) do
        doc = JSON.parse(open("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=#{URI.encode(searchterm)}&rsz=8&#{color.nil? ? '' : '&imcolor=' + color}", "Referer" => "http://lgscout.com").read)
      end
    rescue Timeout::Error
      return "Google is slow! No images for you."
    end
      

    if doc && doc["responseData"] && doc["responseData"]["results"].length > 0
      url = URI.decode(doc["responseData"]["results"][rand(doc["responseData"]["results"].length)]["url"])
      
      if ::Util.wallpaper?(url)
        url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
      end

      log(:images, url)

      url
    else
      "No pictures found! Nuts!"
    end
  end
  
  def self.help
    "!image [searchity search] - Return a relevant picture"
  end
end

