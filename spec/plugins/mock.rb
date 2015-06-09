class MockPlugin < Linkbot::Plugin
  @@messages = []
  @@matches = []

  def self.help; HELP; end

  def self.on_message(message, matches)
    @@messages << message
    @@matches << matches

    ["body: #{message.body}", "matches: #{matches.join(', ')}"]
  end

  def self.messages; @@messages; end
  def self.matches; @@matches; end

  Linkbot::Plugin.register('mock', self, {:message => {:regex => /(\w+)\s(.*)/, :handler => :on_message, :help => :help}})
end
