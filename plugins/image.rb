require 'open-uri'
require 'image_size'
require 'uri'
require 'cgi'

class Image < Linkbot::Plugin

  def initialize
    register :regex => /!image(?: (.+))?/
    help "!image [searchity search] - Return a relevant picture"
  end

  def on_message(message, matches)
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

    images = []

    begin
      Timeout::timeout(4) do
        images = open(searchurl, "User-Agent" => useragent)
      end
    rescue Timeout::Error
      return "google is slow! No images for you."
    end

    # pull image URLs out of the page
    images = images.read.scan(/var u='(.*?)'/).flatten

    # unescape google octal escapes
    images = images.map { |g| unescape(g) }

    #funnyjunk sucks
    images.reject! {|x| x =~ /fjcdn\.com/}

    return "No images found. Lame." if images.empty?

    url = images.sample

    if wallpaper?(url)
      url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
    end

    return url
  end

  # unescape google urls with octal (!?) escapes into url-encoded hex equivalents
  def unescape(url)
    url.gsub(/\\(\d{2})/) do |escape|
      # given an octal escape like '\\75':
      #
      # 1. strip the leading slash
      # 2. convert to an integer
      # 3. convert to a hex string (url escaped)
      "%#{escape[1..-1].to_i(8).to_s(16)}"
    end
  end
end
