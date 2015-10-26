class Party < Linkbot::Plugin
  include HTTParty

  def initialize
    register :regex => /^!partymode (on|off)/i
    help "!partymode (on|off) - PARTAY."
  end

  def on_message(message, matches)
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

end
