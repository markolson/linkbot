class Boo < Linkbot::Plugin
  include HTTParty
  
  Linkbot::Plugin.register('boo', self, {
    :message => {:regex => /^bo+\b/i, :handler => :on_message}
  })

  def self.on_message(message, matches)
    if Linkbot::Config["plugins"]["boo"]["webhook"]
      puts "YEAH"
      get(Linkbot::Config["plugins"]["boo"]["webhook"])
    end
    
    "http://i.imgur.com/nx70H.jpg"
  end
end
