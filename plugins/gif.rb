require 'open-uri'
require 'hpricot'

class Gif < Linkbot::Plugin

  register :regex => /!gif(?: (.+))?/i
  help "!gif [search term] - get a gif from reddit based on the optional search term"

  def self.on_message(message, matches)
    searchterm = matches[0]
    if searchterm.nil?
      searchterm = message_history(message)[0]['body']
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

    gifs = gifs.read.scan(/imgurl.*?(http.*?)\\/).flatten

    # un-escape double-escaped codes into escape codes.
    #
    # Yes that makes sense.
    #
    # Read it again.
    #
    # Google turns a url-escaped "%20" -> "\\x20", so this turns "\\x20" -> "%20" to make it a URL again
    gifs = gifs.map{|x| x.sub(/\\x(\d+)/, "%\\1")}

    #funnyjunk sucks
    gifs.reject! {|x| x =~ /fjcdn\.com/}

    return "No gifs found. Lame." if gifs.empty?

    gifs.sample
  end
end
