require 'open-uri'
require 'hpricot'

class Gif < Linkbot::Plugin

  def self.help
    "!gif [search term] - get a gif from reddit based on the optional search term"
  end

  create_log(:images)

  def self.on_message(message, matches)
    searchterm = matches[0]
    if searchterm.nil?
      searchterm = message_history(message)[0]['body']
      if searchterm == "!image"
        doc = Hpricot(open("http://www.randomword.net").read)
        searchterm = doc.search("#word h2").text.strip
      end
    end

    gifs = []

    begin
      # Give google 2 seconds to respond (and for us to parse it!)
      Timeout::timeout(2) do
        searchurl = "https://www.google.com/search?hl=en&safe=off&biw=517&bih=1073&site=imghp&tbs=itp%3Aanimated&tbm=isch&sa=1&q=#{URI.encode(searchterm)}&oq=bananas&gs_l=img.3..0l10.1894734.1895319.0.1896030.7.6.0.1.1.1.109.435.5j1.6.0...0.0...1c.1.7.img.4-MDM6JAaIY"

        gifs = open(searchurl).read.scan /imgurl=(http:\/\/.*?)&/

      end
    rescue Timeout::Error
      return "Google is slow! No images for you."
    end

    return "No gifs found. Lame." if gifs.empty?

    gifs.sample
  end

  Linkbot::Plugin.register('gif', self, {
    :message => {:regex => /!gif(?: (.+))?/i, :handler => :on_message, :help => :help}
  })
end
