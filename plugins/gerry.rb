require 'uri'

class Gerry < Linkbot::Plugin
  include HTTParty
  
  Linkbot::Plugin.register('gerry', self, {
    :message => {:regex => /^\/gerry/i, :handler => :on_message, :help => :help}
  })

  def self.on_message(message, matches)
    statement = "gerry gerry gerry gerry gerry gerry gerry gerry gerry gerry gerry"
    pics = "(gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) "
    if Linkbot::Config['plugins']['tts'] &&
      Linkbot::Config['plugins']['tts']['webhook']
      get("#{Linkbot::Config['plugins']['tts']['webhook']}/#{URI.encode(statement)}")
    end
    pics
  end
  
  def self.help
    "/gerry - GERRY GERRY GERRY"
  end
end
