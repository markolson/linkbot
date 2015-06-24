require 'open-uri'
require 'hpricot'

class Cinemagraph < Linkbot::Plugin

  def initialize
    register :regex => /!cinemagraph/i
    help "!cinemagraph - get a fancy gif"
  end

  def on_message(message, matches)
    if rand(2) == 1
      url = URI.parse('http://www.gif.tv/gifs/get.php')
      res = Net::HTTP.get(url)
      "http://www.gif.tv/gifs/#{res}.gif"
    else
      page = rand(46)
      doc = Hpricot(open("http://iwdrm.tumblr.com/page/#{page}").read)
      imgs = doc.search("div[@class=post] img")
      imgs = imgs.find_all { |x| x.attributes["src"].match /media.tumblr/ }
      imgs[rand(imgs.length)].attributes["src"]
    end
  end
end
