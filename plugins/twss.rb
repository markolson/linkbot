require 'twss'

class Twss < Linkbot::Plugin
    def self.on_message(message, matches, msg)
      TWSS.threshold = 2.0 #lower = 'better'
      if TWSS(message) and 1 < 0
        "That's what she said"
      else
        ""
      end
    end

    Linkbot::Plugin.register('twss', self,
      {
        :message => {:handler => :on_message}
      }
    )
end


