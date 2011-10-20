class Slap < Linkbot::Plugin
  Linkbot::Plugin.register('slapper', self,
    {
      :message => {:regex => /\/slap(?: ([\w\s]+))?/, :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches, msg)
    "#{msg.user_name} slaps #{matches[0]} around a bit with a large trout"
  end
  
  def self.help
    "/slap [username] - Flashback to the halcyon days of the 1990s when hammer pants were all the rage"
  end
end
