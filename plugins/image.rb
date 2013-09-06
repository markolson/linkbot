require 'open-uri'
require 'image_size'
require 'uri'
require 'cgi'

class Image < Linkbot::Plugin

  Linkbot::Plugin.register('image', self,
    {
      :message => {:regex => /!image(?: (.+))?/, :handler => :on_message, :help => :help}
    }
  )

  create_log(:images)

  def self.on_message(message, matches)
    searchterm = matches[0]
    color = nil
    if searchterm.nil?
      searchterm = message_history(message)[0]['body']
      if searchterm == "!image"
        doc = Hpricot(open("http://www.randomword.net").read)
        searchterm = doc.search("#word h2").text.strip
      end
    end

    imgs = []

    begin
      # Give google 2 seconds to respond (and for us to parse it!)
      Timeout::timeout(2) do
        searchurl = "https://www.google.com/search?q=#{URI.encode(searchterm)}&site=imghp&safe=on&tbm=isch&source=lnt&tbs=isz:lt,islt:qsvga&sa=X&ei=s7v7UbOIK8_J4AOo24HwAw&ved=0CBwQpwU&biw=1673&bih=1062"

        imgs = open(searchurl).read.scan(/imgurl=(http:\/\/.*?)&/).flatten
      end
    rescue Timeout::Error
      return "Google is slow! No images for you."
    end

    #funnyjunk sucks
    imgs.reject! {|x| x =~ /fjcdn\.com/}

    return "No images found. Lame." if imgs.empty?

    imgs.sample
  end

  def self.help
    "!image [searchity search] - Return a relevant picture"
  end
end

