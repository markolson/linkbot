class Timer < Linkbot::Plugin

  @@active = 0

  def self.help
    "!timer <seconds> [message] - set a timer, optionally saying something."
  end

  def self.on_message(message, matches)
    if @@active >= 5
      "There are currently 5 timers running. Wait your turn."
    elsif matches[0].to_i > 300
      "Timers cannot be longer than 5 minutes"
    else
      @@active++
      seconds = matches[0].to_i
      message = matches[1].length > 0 ? matches[1] : "NURRRRRR ALARM NURRRRR"
      sleep(seconds)
      @@active--
      message
    end
  end

  Linkbot::Plugin.register('timer', self, {
    :message => {:regex => /!timer (\d+)\s?(.*)/i, :handler => :on_message, :help => :help}
  })
end
