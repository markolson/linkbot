require 'uri'

class Gerry < Linkbot::Plugin
  include HTTParty

  def initialize
    register :regex => /^\/gerry/i
    help "/gerry - GERRY GERRY GERRY"
  end

  def on_message(message, matches)
    statement = "gerry gerry gerry gerry gerry gerry gerry gerry gerry gerry gerry"
    pics = "(gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) (gerry) "
    if Linkbot::Config['plugins']['tts'] &&
      Linkbot::Config['plugins']['tts']['webhook']
      get("#{Linkbot::Config['plugins']['tts']['webhook']}/#{URI.encode(statement)}")
    end
    pics
  end

end
