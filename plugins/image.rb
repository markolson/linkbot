require 'open-uri'
require 'image_size'
require 'uri'
require 'cgi'

class Image < Linkbot::Plugin
  @@resolutions = {
    "800x600" => true,
    "1024x600" => true,
    "1024x768" => true,
    "1152x864" => true,
    "1280x720" => true,
    "1280x768" => true,
    "1280x800" => true,
    "1280x960" => true,
    "1280x1024" => true,
    "1360x768" => true,
    "1366x768" => true,
    "1440x900" => true,
    "1600x900" => true,
    "1600x1200" => true,
    "1680x1050" => true,
    "1920x1080" => true,
    "1920x1200" => true,
    "2560x1440" => true
  }
  
  Linkbot::Plugin.register('image', self,
    {
      :message => {:regex => /!image(?: (.+))?/, :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches) 
    searchterm = matches[0]
    color = nil
    if searchterm.nil?
      searchterm = message_history[1]['body']
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
    doc = JSON.parse(open("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=#{URI.encode(searchterm)}&rsz=8&safe=off#{color.nil? ? '' : '&imcolor=' + color}", "Referer" => "http://lgscout.com").read)
    if doc["responseData"]["results"].length > 0
      url = URI.decode(doc["responseData"]["results"][rand(doc["responseData"]["results"].length)]["url"])
      
      d = nil
      open(url) do |fh|
        d = ImageSize.new(fh.read).get_size
      end
      
      if @@resolutions.has_key?("#{d[0]}x#{d[1]}")
        url = "#{url}\nWALLPAPER WALLPAPER WALLPAPER WALLPAPER WALLPAPER"
      end
      url
    else
      "No pictures found! Nuts!"
    end
  end
  
  def self.help
    "!image [searchity search] - Return a relevant picture"
  end
end

