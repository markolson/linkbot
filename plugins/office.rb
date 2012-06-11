
class Office < Linkbot::Plugin
  Linkbot::Plugin.register('office', self,
    {
      :message => {:regex => Regexp.new('!office(?: (.+))?'), :handler => :on_message, :help => :help},
    }
  )
  
  def self.on_message(message, matches) 
    # Check to see if the user is setting their own IP address
    command = matches[0]
    messages = []
    if command =~ /setip (.*)/
      Linkbot.db.execute("update presence set user_id='#{message.user_id}' where ip='#{$1}'")
    else
      if matches[0] && matches[0].length > 0
        matches = Linkbot.db.execute("select distinct(u.username) from users u,presence p where u.user_id=p.user_id AND p.present=1 AND u.username LIKE '%#{matches[0]}%'")
        messages = matches.map {|e| e[0] }
      else
        matches = Linkbot.db.execute("select distinct(u.username) from users u,presence p where u.user_id=p.user_id AND p.present=1")
        messages = matches.map {|e| e[0] }
      end
    end
    messages.join(", ")
  end
  
  def self.help
    "!office <user> - show who is currently in the office, or see if the specified user is in the office"
  end
end
