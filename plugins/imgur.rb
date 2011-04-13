require 'open-uri'
require 'hpricot'

class Imgur < Linkbot::Plugin
  def self.regex
    /!imgur/
  end
  Linkbot::Plugin.register('imgur', self.regex, self)
  
  def self.on_message(user, message, matches) 
    imgs = []
    puts "loading images"
    1.upto(3) do |x|
      doc = Hpricot(open("http://imgur.com/gallery?p=#{x}").read)
      puts doc
      imgs += doc.search("div[@class=post] a img").collect do |m|
        puts m
        m.attributes["src"].gsub("b.jpg", ".jpg")
      end
    end
    img = imgs[rand(imgs.length)]

    puts "returning #{img}, #{imgs}"

    [img]
  end
  
  def self.help
    "!imgur - return a random top picture"
  end
end

