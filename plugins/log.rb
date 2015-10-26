class MessageLog < Linkbot::Plugin

  def initialize
    register :regex => //
  end

  def on_message(message, matches)
    log(message)
    ""
  end
end
