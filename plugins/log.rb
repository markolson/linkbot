class MessageLog < Linkbot::Plugin
  Linkbot::Plugin.register('log', self,
    {
      :message => {:handler => :on_message}
    }
  )
  
  def self.on_message(message, matches)
    # Pop off a message if we've reached our max
    if @@message_logs[:global].length >= 100
      @@message_logs[:global].pop
    end
    @@message_logs[:global].unshift(message)
    
    if message[:options][:room]
      if @@message_logs[message[:options][:room]].length >= 100
        @@message_logs[message[:options][:room]].pop
      end
      @@message_logs[message[:options][:room]].unshift(message)
    end
    
    if message[:options][:user]
      if @@message_logs[message[:options][:user]].length >= 100
        @@message_logs[message[:options][:user]].pop
      end
      @@message_logs[message[:options][:user]].unshift(message)
    end
    ""
  end
end
