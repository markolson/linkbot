class Awwyeah < Linkbot::Plugin
    register :regex => /a+w+ y+e+a+h+/i

    def self.on_message(message, matches)
      "http://i.imgur.com/Y3Q0Z.png"
    end

end
