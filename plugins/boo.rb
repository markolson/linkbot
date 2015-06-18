class Boo < Linkbot::Plugin
  include HTTParty

  register :regex => /^bo+\b/i

  def self.on_message(message, matches)
    if Linkbot::Config["plugins"]["boo"]["webhook"]
      puts "YEAH"
      get(Linkbot::Config["plugins"]["boo"]["webhook"])
    end

    "http://i.imgur.com/nx70H.jpg"
  end
end
