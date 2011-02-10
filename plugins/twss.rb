class Twss < Linkbot::Plugin
    def self.regex
      Regexp.new('more wood|push it in|break it off|inside my mouth|into my eyes|won\'t come out|i can\'t stop|in all the way|one this big|suck on it|guys on me|try the other hole|too short|do the big one|with your ball|just do it|make it squirt|sucking so hard|nothing comes out|suck so hard|it was hung|sucks hard|COMING IN MY MOUTH', 'i')
    end
  
    def self.on_message(user, message, matches)
      ["That's what she said"]
    end
    Linkbot::Plugin.register('what she said', self.regex, self)
end
