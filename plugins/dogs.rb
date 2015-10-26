class Dogs < Linkbot::Plugin

  def initialize
    register :regex=> /^!dogs$/i
    help "!dogs - show a random dog GIF"
  end

  def on_message(message, matches)
    dogstreamer = "http://dogstreamer.herokuapp.com/dog"
    gif = open(dogstreamer).read
    gif
  end

end
