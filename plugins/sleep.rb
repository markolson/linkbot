class Sleep < Linkbot::Plugin
  def self.regex
    /!sleep/
  end
  Linkbot::Plugin.register('sleeper', self.regex, self)
  
  def self.on_message(user, message, matches) 
    p "entering in #{Thread.current.object_id}"
    sleep(5)
    p "leaving #{Thread.current.object_id}"
    []
  end
end