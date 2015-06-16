require 'certifi'
require 'httparty'
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

    url = "https://www.youtube.com/results?search_query=#{searchterm}"
    body = HTTParty.get(url, {ssl_ca_file: Certifi.where})
    watch = body.to_s.scan(/a href="(\/watch[^&]*?)"/)[0][0]
    "https://www.youtube.com#{watch}"
  end
end
