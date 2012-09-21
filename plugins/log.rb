class MessageLog < Linkbot::Plugin
  Linkbot::Plugin.register('log', self,
    {
      :message => {:handler => :on_message}
    }
  )
  
  def self.on_message(message, matches)
    log(:global, message)
    log(message[:options][:room], message) if message[:options][:room]
    log(message[:options][:user], message) if message[:options][:user]
    ""
  end
end
