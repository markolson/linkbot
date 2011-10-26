require 'net/http'
require 'uri'
require 'cgi'

class Translate < Linkbot::Plugin
    def self.on_message(message, matches)
      res = Net::HTTP.post_form(URI.parse('http://www.cs.utexas.edu/users/jbc/bork/bork.cgi'),
                                 {'input'=> CGI.unescapeHTML(message_history[1]['body']), 'type'=>'chef'})
      CGI::unescape(res.body.to_s.gsub("&epus;","'"))
    end
    
    def self.help
      "!translate - Trunslete-a zee lest messege-a"
    end
    
    Linkbot::Plugin.register('translate', self,
      {
        :message => {:regex => /!translate/, :handler => :on_message, :help => :help}
      }
    )
end
