class Slap < Linkbot::Plugin
  def self.regex
    /!sleep/
  end
  Linkbot::Plugin.register('slapper', self.regex, self)
  
  def self.on_message(user, message, matches) 
    p "entering in #{Thread.current.object_id}"
    sleep(5)
    p "leaving #{Thread.current.object_id}"
    []
  end
end