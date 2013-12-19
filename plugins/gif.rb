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
    end

    gifs = []

    begin
      # Give google 2 seconds to respond (and for us to parse it!)
      Timeout::timeout(2) do
        searchurl = "https://www.google.com/search?site=imghp&tbs=itp:animated&tbm=isch&q=#{URI.encode(searchterm)}&oq=bananas&gs_l=img.3..0l10.112228.112858.0.113513.7.5.0.2.2.0.91.408.5.5.0....0...1c.1.32.img..0.7.416.dxM6ig7fTKY&bav=on.2,or.r_qf.&bvm=bv.58187178,d.eW0,pv.xjs.s.en_US.EeLgqkzqnSg.O&biw=1377&bih=1188&dpr=1&safe=active"
        # this is an old iphone user agent. Seems to make google return good results.
        useragent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"

        gifs = open(searchurl, "User-Agent" => useragent).read.scan(/http:\/\/[\/\.\w\-~]*?\.gif/)
      end
    rescue Timeout::Error
      return "Google is slow! No gifs for you."
    end

    #funnyjunk sucks
    gifs.reject! {|x| x =~ /fjcdn\.com/}

    return "No gifs found. Lame." if gifs.empty?

    gifs.sample
  end

  Linkbot::Plugin.register('gif', self, {
    :message => {:regex => /!gif(?: (.+))?/i, :handler => :on_message, :help => :help}
  })
end
