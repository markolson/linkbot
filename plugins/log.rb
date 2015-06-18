class MessageLog < Linkbot::Plugin
  
  register

  def self.on_message(message, matches)
    log(message)
    ""
  end
end
