class Alex < Linkbot::Plugin
    def self.on_message(message, matches, msg) 
      "http://i.imgur.com/2AA7y.png"
    end

    Linkbot::Plugin.register('alex', self,
      {
        :message => {:regex => Regexp.new('/alex'), :handler => :on_message}
      }
    )
end
