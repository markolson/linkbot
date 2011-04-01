require 'open-uri'
require 'hpricot'

class Imgur < Linkbot::Plugin
  def self.regex
    /!imgur/
  end
  Linkbot::Plugin.register('imgur', self.regex, self)
  
  def self.on_message(user, message, matches) 
    imgs = []
    1.upto(3) do |x|
      doc = Hpricot(open("http://imgur.com/gallery?p=#{x}").read)
      imgs += doc.search("div[@class=big-preview] a img").collect{|m| m.attributes["src"].gsub("b.jpg", ".jpg")}
    end
    
    #reduce dupes
    img = ""
    attempts = 0
    while unique_link == false do
      img = imgs[rand(imgs.length)]
      if link_unique?(img)
        #add img to db
        p "inserted img to db"
        #Linkbot.db.execute("insert into links (user_id, dt, url) VALUES ('0', '#{Time.now.getgm.to_i}', '#{img}')") ) 
        unique_link = true
      end

      attempts += 1
      
      #give up after 20 attempts
      break if attempts > 20
    end

    [img]
  end
 
  def link_unique?(link)
      Linkbot.db.execute("select url from links where url == '#{link}'").nil?
  end
  
  def self.help
    "!imgur - return a random top picture"
  end
end
