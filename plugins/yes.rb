require 'open-uri'

class Yes < Linkbot::Plugin
  Linkbot::Plugin.register('yes', self, {
    :message => {:regex => /!yes/i, :handler => :on_message, :help => :help}
  })

  def self.help
    "!yes - Let someone know you agree"
  end

  def self.on_message(message, matches)
    open('http://www.reactiongifs.com/gallery/yes/').read.scan(/href="(http:\/\/.*?.gif)"/).flatten.sample
  end
end
