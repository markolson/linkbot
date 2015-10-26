require 'active_support'

class Onion < Linkbot::Plugin
  def initialize
    register :regex => Regexp.new('!onion')
    help "!onion - return an onion link from the RSS feed"
  end

  def on_message(message, matches)
    links = Hpricot(open('http://feeds.theonion.com/theonion/daily')).search('feedburner:origlink').collect{|l| l.html}
    links[rand(links.length)]
  end

end
