class MessageLog < Linkbot::Plugin
  Linkbot::Plugin.register('log', self,
    {
      :message => {:handler => :on_message}
    }
  )

  def self.on_message(message, matches)
    log(message)
    ""
  end
end
