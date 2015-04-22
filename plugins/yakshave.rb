class Yakshave < Linkbot::Plugin
    def self.on_message(message, matches)
      "https://i.imgur.com/t0XHtgJ.gif"
    end

    Linkbot::Plugin.register('yakshave', self,
      {
        :message => {:regex => /(yakshave|yak shave|shaving.*yak)/i, :handler => :on_message}
      }
    )
end
