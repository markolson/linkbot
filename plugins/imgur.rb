require 'open-uri'
require 'hpricot'

class Imgur < Linkbot::Plugin
  
  Linkbot::Plugin.register('imgur', self,
    {
      :message => {:regex => /!imgur/, :handler => :on_message, :help => :help},
      :"direct-message" => {:regex => /!imgur/, :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches) 
    imgs = []
    puts "loading images"
    1.upto(3) do |x|
      doc = Hpricot(open("http://imgur.com/gallery?p=#{x}").read)
      imgs += doc.search("div[@class=post] a img").collect do |m|
        m.attributes["src"].gsub("b.jpg", ".jpg")
      end
    end
    img = imgs[rand(imgs.length)]

    img
  end
  
  def self.help
    "!imgur - return a random top picture"
  end
end

