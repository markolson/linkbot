require 'net/http'
require 'uri'
require 'cgi'

class Translate < Linkbot::Plugin

  register :regex => /!translate/
  help "!translate - Trunslete-a zee lest messege-a"

  def self.on_message(message, matches)
    res = Net::HTTP.post_form(URI.parse('http://www.cs.utexas.edu/users/jbc/bork/bork.cgi'),
                               {'input'=> CGI.unescapeHTML(message_history(message)[1]['body']), 'type'=>'chef'})
    CGI::unescape(res.body.to_s.gsub("&epus;","'"))
  end

end
