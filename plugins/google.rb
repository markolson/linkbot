require 'nokogiri'

class Google < Linkbot::Plugin

  def initialize
    register :regex => /!google (.+)/
    help "!google <term>: return the first google result"
  end

  # this is an old iphone user agent. Seems to make google return good results.
  USER_AGENT = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"

  def on_message(message, matches)
    searchterm = Addressable::URI.encode(matches[0])
    doc = Nokogiri::HTML(http_get("https://www.google.com/search?tbm=isch&q=#{searchterm}", {"User-Agent" => USER_AGENT}))
    doc.search("h3.r a")[0].to_s.match(/q=(.*?)&/)[1]
  end

end
