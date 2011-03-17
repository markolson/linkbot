require 'open-uri'
require 'hpricot'

class Imgur < Linkbot::Plugin
  def self.regex
    /!imgur/
  end
  Linkbot::Plugin.register('imgur', self.regex, self)
  
  def self.on_message(user, message, matches) 
    1.upto(3) do |x|
      doc = Hpricot(open("http://imgur.com/gallery?p=#{x}").read)
      imgs = doc.search("div[@class=big-preview] a img").collect{|m| m.attributes["src"].gsub("b.jpg", ".jpg")}
    end

    [imgs[rand(imgs.length)]]
  end
  
  def self.help
    "!imgur - return a random top picture"
  end
end
