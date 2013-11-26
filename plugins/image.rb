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
      # Give imgur 10 seconds to respond (and for us to parse it!)
      Timeout::timeout(10) do
        searchurl = "http://imgur.com/?q=#{URI.encode(searchterm)}"

        imgs = open(searchurl).read.scan(/alt.*?src="(.*?)"/).flatten.map { |x| "http:" + x.gsub("b.", ".") }
      end
    rescue Timeout::Error
      return "imgur is slow! No images for you."
    end

    #funnyjunk sucks
    imgs.reject! {|x| x =~ /fjcdn\.com/}

    return "No images found. Lame." if imgs.empty?

    url = imgs.sample

    if ::Util.wallpaper?(url)
      url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
    end

    return url
  end

  def self.help
    "!image [searchity search] - Return a relevant picture"
  end
end

