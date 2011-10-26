require 'open-uri'
require 'uri'

class Image < Linkbot::Plugin
  
  Linkbot::Plugin.register('image', self,
    {
      :message => {:regex => /!image(?: (.+))?/, :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches) 
    searchterm = matches[0]
    if searchterm.nil?
      doc = Hpricot(open("http://www.randomword.net").read)
      searchterm = doc.search("#word h2").text.strip
    end
    doc = JSON.parse(open("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=#{URI.encode(searchterm)}&rsz=8&safe=off", "Referer" => "http://lgscout.com").read)
    if doc["responseData"]["results"].length > 0
      doc["responseData"]["results"][rand(doc["responseData"]["results"].length)]["url"]
    else
      "No pictures found! Nuts!"
    end
  end
  
  def self.help
    "!image [searchity search] - Return a relevant picture"
  end
end

