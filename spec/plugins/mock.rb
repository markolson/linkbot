class MockPlugin
  def self.help; HELP; end

  attr :message, :matches
  def self.on_message(message, matches)
    @message = message
    @matches = matches
  end

  Linkbot::Plugin.register('mock', self, {:message => {:regex => //, :handler => :on_message, :help => :help}})
end
