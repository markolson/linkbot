class Fuu < Linkbot::Plugin
    def self.regex
      Regexp.new('FUUU')
    end

    def self.on_message(user, message, match)
      ["http://imgur.com/M4KFN.jpg"]
    end
    
    Linkbot::Plugin.register('fuuu', self.regex, self)
end

