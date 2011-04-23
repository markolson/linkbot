class Dumb < Linkbot::Plugin
    def self.on_message(user, message, matches, msg) 
      ["No, you're dumb"]
    end

    Linkbot::Plugin.register('dumb', self,
      {
        :message => {:regex => /dumb|stupid/, :handler => :on_message}
      }
    )
end
