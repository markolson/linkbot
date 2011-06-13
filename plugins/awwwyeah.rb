require 'rubyfish'

class Awwyeah < Linkbot::Plugin
    def self.on_message(user, message, matches, msg)
      m = []
      if RubyFish::LongestSubsequence.distance("aw yeah", message.downcase) == 7
        m = ["http://i.imgur.com/Y3Q0Z.png"]
      elsif  RubyFish::Jaro.distance("aw yeah", message.downcase) > 0.79
        m = ["http://i.imgur.com/Y3Q0Z.png"]
      end
      m
    end

    Linkbot::Plugin.register('awwwyeah', self,
      {
        :message => {:regex => //, :handler => :on_message}
      }
    )
end
