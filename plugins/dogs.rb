class Dogs < Linkbot::Plugin
  
  register :regex=> /^!dogs$/i
  help "!dogs - show a random dog GIF"

  def self.on_message(message, matches)
    dogstreamer = "http://dogstreamer.herokuapp.com/dog"
    gif = open(dogstreamer).read
    gif
  end

end
