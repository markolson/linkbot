class Shutup < Linkbot::Plugin
    def self.regex
      /(.*), linkbot/
    end

    def self.on_message(user, message, match)
      ["No, YOU #{matches[0]}"]
    end

    Linkbot::Plugin.register('shutup', self.regex, self)
end