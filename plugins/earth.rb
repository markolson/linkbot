require 'open-uri'
require 'hpricot'

class Earth < Linkbot::Plugin
  
  help "!earth - get a nice satellite image"
  register :regex => /!earth/i

  def self.on_message(message, matches)
    url = URI.parse('http://www.earthlens.org/')
    doc = Hpricot(open(url).read)
    imgs = doc.search("img")
    # remove category header images
    imgs = imgs.reject{|i| i.parent.attributes["href"].match /\/tag\//}
    # find an images.earthlens image
    imgs = imgs.find_all{|x| x.attributes["src"].match /images.earthlens/}
    # pick a random image
    i = imgs.sample.attributes["src"]
    # and return the full-size version
    i.sub "/square/", "/large/"
  end

end
