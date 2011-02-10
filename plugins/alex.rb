class Alex < Linkbot::Plugin
    def self.regex
      Regexp.new('/alex')
    end

    def self.on_message(user, message, match)
      ["http://i.imgur.com/2AA7y.png"]
    end
    Linkbot::Plugin.register('alex', self.regex, self)
end
