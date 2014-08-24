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
        searchurl = "https://www.google.com/search?safe=active&site=&tbm=isch&source=hp&biw=2538&bih=1188&q=#{URI.encode(searchterm)}&gs_l=img.3..0l10.742.2620.0.2741.13.8.3.2.2.1.322.950.6j1j0j1.8.0....0...1ac.1.32.img..1.12.645.mA4Z_8PcstY"
        # this is an old iphone user agent. Seems to make google return good results.
        useragent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"

        imgs = open(searchurl, "User-Agent" => useragent).read.scan(/imgurl.*?(http.*?)\\/).flatten

        # un-escape double-escaped codes into escape codes.
        #
        # Yes that makes sense.
        #
        # Read it again.
        #
        # Google turns a url-escaped "%20" -> "\\x20", so this turns "\\x20" -> "%20" to make it a URL again
        imgs = imgs.map{|x| x.sub(/\\x(\d+)/, "%\\1")}
      end
    rescue Timeout::Error
      return "google is slow! No images for you."
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

