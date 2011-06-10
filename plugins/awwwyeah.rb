class Awwyeah < Linkbot::Plugin
    def self.on_message(user, message, matches, msg)
      ["http://i.imgur.com/Y3Q0Z.png"]
    end

    Linkbot::Plugin.register('awwwyeah', self,
      {
        :message => {:regex => /a+w+ y+e+a+h+/, :handler => :on_message}
      }
    )
end
