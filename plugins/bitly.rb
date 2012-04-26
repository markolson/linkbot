require 'url_shortener'

# Shortens urls using the public API at Bitly.com
class Bitly < Linkbot::Plugin

  @@config = Linkbot::Config["plugins"]['bitly']

  if @@config
    # configure connection to bitly
    auth = UrlShortener::Authorize.new(@@config["username"], @@config["api_key"])
    @@client = UrlShortener::Client.new auth

    Linkbot::Plugin.register('bitly', self,
           {
               :message => {:regex => /\/bitly(?: (https?:\/\/[\S]+))?/, :handler => :on_message, :help => :help}
           }
    )
  end

  def self.on_message(message, matches)
    shorten = @@client.shorten matches[0]
    shorten.urls
  end

  def self.help
    "/bitly [url] - Shortens the url using Bitly"
  end
end
