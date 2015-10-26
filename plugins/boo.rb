class Boo < Linkbot::Plugin
  include HTTParty

  def initialize
    register :regex => /^bo+\b/i
    @config = Linkbot::Config["plugins"].fetch("boo", {})
    @webhook = @config.fetch("webhook", false)
  end

  def on_message(message, matches)
    if @webhook
      puts "YEAH"
      get(@webhook) # poke some external booing
    end

    "http://i.imgur.com/nx70H.jpg"
  end
end
