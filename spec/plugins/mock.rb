class MockPlugin < Linkbot::Plugin
  @@messages = []
  @@matches = []

  register :regex => //
  help '!mockery - mock plugin that only repeats messages'

  def self.on_message(message, matches)
    @@messages << message
    @@matches << matches

    message.body
  end

  def self.messages; @@messages; end
  def self.matches; @@matches; end

end
