class Okay < Linkbot::Plugin
    def self.on_message(message, matches)
      "http://i.imgur.com/p7uaa.jpg"
    end

    Linkbot::Plugin.register('okay', self,
      {
        :message => {:regex => /okay\./i, :handler => :on_message}
      }
    )
end
