require 'nokogiri'

class Imgur < Linkbot::Plugin

  def initialize
    register :regex => /!imgur/
    help "!imgur - return a random top picture"
  end

  def on_message(message, matches)
    imgs = []
    Linkbot.log.debug "Imgur plugin: loading images"
    1.upto(3) do |x|
      doc = Nokogiri::HTML(http_get("http://imgur.com/gallery?p=#{x}"))
      imgs += doc.search("div.post a img").collect do |m|
        m["src"].gsub("b.jpg", ".jpg")
      end
    end
    url = imgs[rand(imgs.length)]

    if wallpaper?(url)
      url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
    end

    url
  end
end
