class Awwww < Linkbot::Plugin
    def self.on_message(message, matches)
      "http://i.imgur.com/DALJo.jpg"
    end

    Linkbot::Plugin.register('awwww', self,
      {
        :message => {:regex => /^a+w+$/i, :handler => :on_message}
      }
    )
end
