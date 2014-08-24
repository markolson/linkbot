require 'open-uri'
require 'active_support'
require 'cgi'

class Youtube < Linkbot::Plugin
  Linkbot::Plugin.register('youtube', self,
    {
      :message => {:regex => Regexp.new('!youtube(?: (.+))?'), :handler => :on_message, :help => :help},
    }
  )

  def self.help
    "!youtube [query] - return the first youtube result for [query]"
  end

  def self.on_message(message, matches)
    searchterm = matches[0]

    if searchterm.nil?
      searchterm = message_history(message)[1]['body']
    end

    searchterm = CGI.escape(searchterm)

    url = "https://gdata.youtube.com/feeds/api/videos?q=#{searchterm}&orderBy=relevance&alt=json"
    doc = ActiveSupport::JSON.decode(open(url).read)
    first = doc["feed"]["entry"][0]
    first["link"][0]["href"]
  end
end
