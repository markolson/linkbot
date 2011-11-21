require 'uri'

class TTS < Linkbot::Plugin
  include HTTParty
  
  Linkbot::Plugin.register('tts', self, {
    :message => {:regex => /^!tts (.+)/i, :handler => :on_message, :help => :help}
  })

  def self.on_message(message, matches)
    if Linkbot::Config['plugins']['tts']['webhook']
      get("#{Linkbot::Config['plugins']['tts']['webhook']}/#{URI.encode(matches[0])}")
    end
    ''
  end
  
  def self.help
    "!tts (text to say) - SAY IT"
  end
end
