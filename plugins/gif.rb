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
        # giphy uses dashes instead of %20 *shrug*
        searchterm = searchterm.gsub(" ", "-")
        searchurl = "http://giphy.com/search/#{URI.encode(searchterm)}"

        gifs = open(searchurl).read.scan(/data-animated="(http:\/\/.*?)"/).flatten
      end
    rescue Timeout::Error
      return "Giphy is slow! No gifs for you."
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
