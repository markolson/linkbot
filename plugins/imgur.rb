require 'open-uri'
require 'hpricot'

class Imgur < Linkbot::Plugin
  def self.regex
    /!imgur/
  end
  Linkbot::Plugin.register('imgur', self.regex, self)
  
  def self.on_message(user, message, matches) 
    links = []
    1.upto(3) do |x|
      doc = Hpricot(open("http://imgur.com/gallery?p=#{x}").read)
      matches = doc.search("div[@class=big-preview] a")
      matches.each do |match|
        links << match.get_attribute("href")
      end
    end

    url = links[rand(links.length)]
    [url]
  end
  
  def self.help
    "!imgur - return a random top picture"
  end
end