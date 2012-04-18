class Timer < Linkbot::Plugin

  def self.help
    "!timer <seconds> - set a timer"
  end

  def self.on_message(message, matches)
    seconds = matches[0].to_i
    sleep(seconds)
    "NURRRRRRRR ALARM NURRRRRRR"
  end

  Linkbot::Plugin.register('timer', self, {
    :message => {:regex => /!timer (\d+)/i, :handler => :on_message, :help => :help}
  })
end
