class Slap < Linkbot::Plugin
  def self.regex
    /\/slap(?: ([\w\s]+))?/
  end
  Linkbot::Plugin.register('slapper', self.regex, self)
  
  def self.on_message(user, message, matches) 
    ["#{user} slaps #{matches[0]} around a bit with a large trout"]
  end
  
  def self.help
    "/slap [username] - Flashback to the halcyon days of the 1990s when hammer pants were all the rage"
  end
end