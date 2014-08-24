class Say < Linkbot::Plugin
  
  Linkbot::Plugin.register('say', self, {
    :message => {:regex => /^!say (.+)/i, :handler => :on_message, :help => :help}
  })

  def self.on_message(message, matches)
    "#{matches[0]}"
  end
  
  def self.help
    "!say (phrase) - Make linkbot repeat after you. Not that useful."
  end
end
