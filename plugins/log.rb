class MessageLog < Linkbot::Plugin
  Linkbot::Plugin.register('log', self,
    {
      :message => {:handler => :on_message}
    }
  )
  
  def self.on_message(message, matches)
    # Pop off a message if we've reached our max
    if @@message_log.length >= 100
      @@message_log.pop
    end
    
    @@message_log.unshift(message)
    ""
  end
end
