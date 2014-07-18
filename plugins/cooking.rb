class Cooking < Linkbot::Plugin
    Linkbot::Plugin.register('cooking', self,
      {
        :message => {:regex => /cook(ed|ing|in|\s)/i, :handler => :on_message}
      }
    )

    def self.on_message(message, matches)
      "http://25.media.tumblr.com/tumblr_lpzmvaXyzj1qa3j66o1_500.gif"
    end

end
