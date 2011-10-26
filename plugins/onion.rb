require 'active_support'

class Onion < Linkbot::Plugin
  Linkbot::Plugin.register('onion', self,
    {
      :message => {:regex => Regexp.new('!onion'), :handler => :on_message, :help => :help},
      :"direct-message" => {:regex => Regexp.new('!onion'), :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches) 
    links = Hpricot(open('http://feeds.theonion.com/theonion/daily')).search('feedburner:origlink').collect{|l| l.html}
    links[rand(links.length)]
  end
  
  def self.help
    "!onion - return an onion link from the RSS feed"
  end
end
