require 'open-uri'
require 'hpricot'

class Gif < Linkbot::Plugin

  def initialize
    register :regex => /!gif(?: (.+))?/i
    help "!gif [search term] - get a gif from reddit based on the optional search term"
  end

  def on_message(message, matches)
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
    searchurl = "https://www.google.com/search?tbs=itp:animated&tbm=isch&q=#{searchterm}&safe=active"

    # this is an old iphone user agent. Seems to make google return good results.
    useragent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"

    gifs = []

    begin
      Timeout::timeout(4) do
        gifs = open(searchurl, "User-Agent" => useragent)
      end
    rescue Timeout::Error
      return "Google is slow! No gifs for you."
    end

    # pull gif URLs out of the page
    gifs = gifs.read.scan(/var u='(.*?)'/).flatten

    # unescape google octal escapes
    gifs = gifs.map { |g| unescape_octal(g) }

    #funnyjunk sucks
    gifs.reject! {|x| x =~ /fjcdn\.com/}

    return "No gifs found. Lame." if gifs.empty?

    gifs.sample
  end

  def random_word
    doc = Hpricot(open("http://www.randomword.net").read)
    doc.search("#word h2").text.strip
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
