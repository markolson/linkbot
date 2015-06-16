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

    searchterm = URI.encode(searchterm)
    searchurl = "https://www.google.com/search?tbm=isch&q=#{searchterm}&safe=active"

    # this is an old iphone user agent. Seems to make google return good results.
    useragent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"

    imgs = []

    begin
      Timeout::timeout(4) do
        imgs = open(searchurl, "User-Agent" => useragent)
      end
    rescue Timeout::Error
      return "google is slow! No images for you."
    end

    imgs = imgs.read.scan(/imgurl.*?(http.*?)\\/).flatten

    # un-escape double-escaped codes into escape codes.
    #
    # Yes that makes sense.
    #
    # Read it again.
    #
    # Google turns a url-escaped "%20" -> "\\x20", so this turns "\\x20" -> "%20" to make it a URL again
    imgs = imgs.map{|x| x.sub(/\\x(\d+)/, "%\\1")}


    #funnyjunk sucks
    imgs.reject! {|x| x =~ /fjcdn\.com/}

    return "No images found. Lame." if imgs.empty?

    url = ensure_image_extension imgs.sample

    if ::Util.wallpaper?(url)
      url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
    end

    return url
  end

  def self.help
    "!image [searchity search] - Return a relevant picture"
  end

  def self.ensure_image_extension(url)
    ext = url.split('.').pop()
    if ext =~ /(png|jpe?g|gif)$/i
      url
    else
      "#{url}#.png"
    end
  end
end

