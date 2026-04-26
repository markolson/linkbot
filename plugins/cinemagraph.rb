require 'nokogiri'

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
      page = rand(31)
      doc = Nokogiri::HTML(http_get("http://iwdrm.tumblr.com/page/#{page}"))
      imgs = doc.search("div.post img")
      imgs = imgs.find_all { |x| x["src"]&.match /media.tumblr/ }
      imgs[rand(imgs.length)]["src"]
    end
  end
end
