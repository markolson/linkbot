class Shutup < Linkbot::Plugin
    def self.on_message(user, message, matches, msg)
      ["No, YOU #{matches[0]}"]
    end

    Linkbot::Plugin.register('shutup', self,
      {
        :message => {:regex => /(.*), linkbot/, :handler => :on_message}
      }
    )
end