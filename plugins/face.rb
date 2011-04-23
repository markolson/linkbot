class Face < Linkbot::Plugin
    def self.on_message(user, message, matches, msg)
      ["http://i.imgur.com/ZbfvQ.gif"]
    end

    Linkbot::Plugin.register('face', self,
      {
        :message => {:regex => Regexp.new('/face'), :handler => :on_message}
      }
    )
end