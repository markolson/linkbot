require 'uri'

class TTS < Linkbot::Plugin
  include HTTParty

  def initialize
    register :regex => /^!tts(?: (.+))?/i
    help "!tts (text to say) - SAY IT"
  end

  def on_message(message, matches)
    statement = matches[0]
    if Linkbot::Config['plugins']['tts']['webhook']
      if statement.nil?
        statement = message_history(message)[1]['body']
      end
      get("#{Linkbot::Config['plugins']['tts']['webhook']}/#{URI.encode(statement)}")
    end
    ''
  end

end
