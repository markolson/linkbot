require 'open-uri'
require 'hpricot'

class Imgur < Linkbot::Plugin

  def initialize
    register :regex => /!imgur/
    help "!imgur - return a random top picture"
  end

  def on_message(message, matches)
    imgs = []
    puts "loading images"
    1.upto(3) do |x|
      doc = Hpricot(open("http://imgur.com/gallery?p=#{x}").read)
      imgs += doc.search("div[@class=post] a img").collect do |m|
        m.attributes["src"].gsub("b.jpg", ".jpg")
      end
    end
    url = imgs[rand(imgs.length)]

    if wallpaper?(url)
      url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
    end

    url
  end
end
