class Face < Linkbot::Plugin
    def self.on_message(message, matches)
      "http://i.imgur.com/ZbfvQ.gif"
    end

    Linkbot::Plugin.register('face', self,
      {
        :message => {:regex => Regexp.new('/face'), :handler => :on_message}
      }
    )
end
