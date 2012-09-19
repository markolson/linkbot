require 'uri'

class TTS < Linkbot::Plugin
  include HTTParty
  
  Linkbot::Plugin.register('tts', self, {
    :message => {:regex => /^!tts(?: (.+))?/i, :handler => :on_message, :help => :help}
  })

  def self.on_message(message, matches)
    statement = matches[0]
    if Linkbot::Config['plugins']['tts']['webhook']
      if statement.nil?
        statement = message_history(message)[1]['body']
      end
      get("#{Linkbot::Config['plugins']['tts']['webhook']}/#{URI.encode(statement)}")
    end
    ''
  end
  
  def self.help
    "!tts (text to say) - SAY IT"
  end
end
