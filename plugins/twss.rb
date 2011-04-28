require 'twss'

class Twss < Linkbot::Plugin
    def self.on_message(user, message, matches, msg)
      TWSS.threshold = 2.0 #lower = 'better'
      if TWSS(message)
        ["That's what she said"]
      else
        []
      end
    end

    Linkbot::Plugin.register('twss', self,
      {
        :message => {:handler => :on_message}
      }
    )
end


