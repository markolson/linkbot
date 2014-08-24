class Party < Linkbot::Plugin
  include HTTParty
  
  Linkbot::Plugin.register('party', self, {
    :message => {:regex => /^!partymode (on|off)/i, :handler => :on_message, :help => :help}
  })

  def self.on_message(message, matches)
    if matches[0] == "on"
      if Linkbot::Config["plugins"]["party"] && Linkbot::Config["plugins"]["party"]["on_hooks"]
        Linkbot::Config["plugins"]["party"]["on_hooks"].each do |hook|
          get(hook)
        end
      end
      '(boom) (dance) (dealwithit) PARTAAAAAAAAAAAY (dealwithit) (dance) (boom)'
    else
      if Linkbot::Config["plugins"]["party"] && Linkbot::Config["plugins"]["party"]["off_hooks"]
        Linkbot::Config["plugins"]["party"]["off_hooks"].each do |hook|
          get(hook)
        end
      end
      '(indeed) Party over. (indeed)'
    end
  end
  
  def self.help
    "!partymode (on|off) - PARTAY."
  end
end
