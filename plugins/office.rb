
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
    message = ''
    if command =~ /setip (.*)/
      Linkbot.db.execute("update presence set user_id='#{message.user_id}' where ip='#{$1}'")
    else
      if matches[0] && matches[0].length > 0
        matches = Linkbot.db.execute("select u.username,p.present,max(p.last_seen) from users u,presence p where u.user_id=p.user_id AND u.username LIKE '%#{matches[0]}%' GROUP BY u.username ORDER BY p.present DESC")
        messages = matches.map {|e| 
          if e[1].to_i == 0
            messages << "#{e[0]} (out of office, last seen #{Time.at(e[2].to_i)})"
          else
            messages << "#{e[0]} (in office)"
          end 
        }
        if messages.empty?
          messages << "No one is in the office currently with that name."
        end
        message = messages.join("\n")
      else
        matches = Linkbot.db.execute("select distinct(u.username) from users u,presence p where u.user_id=p.user_id AND p.present=1")
        messages = matches.map {|e| e[0] }
        if messages.empty?
          messages << "No one is in the office."
        end
        message = messages.join(", ")
      end
    end
    
    message
    
  end
  
  def self.help
    "!office <user> - show who is currently in the office, or see if the specified user is in the office"
  end
end
