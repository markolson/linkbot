require 'open-uri'

class Yes < Linkbot::Plugin
  register :regex => /!yes/i
  help "!yes - Let someone know you agree"

  def self.on_message(message, matches)
    open('http://www.reactiongifs.com/gallery/yes/').read.scan(/href="(http:\/\/.*?.gif)"/).flatten.sample
  end
end
