class Haha < Linkbot::Plugin
    def self.on_message(message, matches, msg) 
      ["http://nelsonhaha.com/"]
    end

    Linkbot::Plugin.register('haha', self,
      {
        :message => {:regex => /ha ha/, :handler => :on_message}
      }
    )
end
