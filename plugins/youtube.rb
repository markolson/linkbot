require 'certifi'
require 'httparty'
require 'active_support'
require 'cgi'

class Youtube < Linkbot::Plugin

  def initialize
    register :regex => Regexp.new('!youtube(?: (.+))?')
    help "!youtube [query] - return the first youtube result for [query]"
  end

  def on_message(message, matches)
    searchterm = matches[0]

    if searchterm.nil?
      searchterm = message_history(message)[1]['body']
    end

    searchterm = CGI.escape(searchterm)

    url = "https://www.youtube.com/results?search_query=#{searchterm}"
    body = HTTParty.get(url, {ssl_ca_file: Certifi.where})
    watch_link_scan = body.to_s.scan(%r{watch\?v=\w*})
    if watch = watch_link_scan[0]
      "https://www.youtube.com/#{watch}"
    else
      "Couldn't find videos."
    end
  end
end
