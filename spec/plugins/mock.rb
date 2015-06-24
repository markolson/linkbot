class MockPlugin < Linkbot::Plugin
  def initialize
    @messages = []
    @matches = []

    register :regex => //
    help '!mockery - mock plugin that only repeats messages'
  end

  def on_message(message, matches)
    @messages << message
    @matches << matches

    message.body
  end

  def messages; @messages; end

end
