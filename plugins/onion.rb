require 'active_support'
require 'nokogiri'

class Onion < Linkbot::Plugin
  def initialize
    register :regex => Regexp.new('!onion')
    help "!onion - return an onion link from the RSS feed"
  end

  def on_message(message, matches)
    doc = Nokogiri::XML(http_get('http://feeds.theonion.com/theonion/daily'))
    doc.remove_namespaces!
    links = doc.search('origlink').collect{|l| l.text}
    links[rand(links.length)]
  end

end
