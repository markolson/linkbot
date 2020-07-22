require 'open-uri'
require 'certifi'
require 'httparty'
require 'image_size'
require 'uri'
require 'cgi'

class Image < Linkbot::Plugin

  def initialize
    register :regex => /\A!(gif|image)(?: (.+))?/i

    help <<~HELP
      !image [searchity search] - Return a relevant picture
      !gif [searchity search] - make that an animated image, barkeep!
    HELP
  end

  def on_message(message, matches)
    color = nil
    gif_requested = message.body.start_with?('!gif ')

    searchterm = matches[0]
    if searchterm.nil?
      past_messages = message_history(message)
      if past_messages
        searchterm = past_messages[0]['body']
      else
        searchterm = random_word
      end
    end

    searchterm = URI.encode(searchterm)
    searchurl = "https://www.google.com/search?tbm=isch&q=#{searchterm}&safe=active"
    searchurl += "&tbs=itp:animated" if gif_requested

    # this is an old iphone user agent. Seems to make google return good results.
    useragent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"

    results = ''

    begin
      Timeout::timeout(4) do
        results = HTTParty.get(searchurl, {
          ssl_ca_file: Certifi.where,
          headers: {"User-Agent" => useragent},
        })
      end
    rescue Timeout::Error
      return "google is slow! No images for you."
    end

    # pull image URLs out of the page
    images = results.scan(/imgres[?]imgurl=(.*?)&amp;/).flatten

    # unescape google octal escapes
    images = images.map { |g| unescape_octal(g) }

    #funnyjunk sucks
    images.reject! {|x| x =~ /fjcdn\.com/}

    return "No images found. Lame." if images.empty?

    url = images.sample

    if !gif_requested && wallpaper?(url)
      url = [url, "(dealwithit) WALLPAPER WALLPAPER WALLPAPER (dealwithit)"]
    end

    return url
  end

  def random_word
    doc = Hpricot(open("http://www.randomword.net").read)
    doc.search("#word h2").text.strip
  end
end
