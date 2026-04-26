require 'nokogiri'

class Earth < Linkbot::Plugin

  def initialize
    help "!earth - get a nice satellite image"
    register :regex => /!earth/i
  end

  def on_message(message, matches)
    url = URI.parse('http://www.earthlens.org/')
    doc = Nokogiri::HTML(http_get(url))
    imgs = doc.search("img")
    # remove category header images
    imgs = imgs.reject{|i| i.parent["href"]&.match /\/tag\//}
    # find an images.earthlens image
    imgs = imgs.find_all{|x| x["src"]&.match /images.earthlens/}
    # pick a random image
    i = imgs.sample["src"]
    # and return the full-size version
    i.sub "/square/", "/large/"
  end

end
