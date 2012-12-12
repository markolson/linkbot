require 'open-uri'
require 'active_support'
require 'cgi'

class Youtube < Linkbot::Plugin
  Linkbot::Plugin.register('youtube', self,
    {
      :message => {:regex => Regexp.new('!youtube(?: (.+))'), :handler => :on_message, :help => :help},
    }
  )

  def self.on_message(message, matches)
    searchterm = CGI.escape(matches[0])
    url = "https://gdata.youtube.com/feeds/api/videos?q=#{searchterm}&orderBy=relevance&alt=json"
    doc = ActiveSupport::JSON.decode(open(url).read)
    first = doc["feed"]["entry"][0]
    first["link"][0]["href"]
  end
end
