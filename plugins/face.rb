class Face < Linkbot::Plugin
    def self.regex
      /\/face/
    end

    def self.on_message(user, message, match)
      ["http://i.imgur.com/ZbfvQ.gif"]
    end

    Linkbot::Plugin.register('face', self.regex, self)
end