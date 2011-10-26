class Fuu < Linkbot::Plugin
    def self.on_message(message, matches)
      "http://imgur.com/M4KFN.jpg"
    end
    
    Linkbot::Plugin.register('fuuu', self,
      {
        :message => {:regex => Regexp.new('FUUU'), :handler => :on_message}
      }
    )
end

