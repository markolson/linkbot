class Dogs < Linkbot::Plugin
  Linkbot::Plugin.register('dogs', self,
    {
      :message => {:regex=> /^!dogs$/i, :handler=> :on_message, :help => :help}
    }
  )

  def self.on_message(message, matches)
    dogstreamer = "http://dogstreamer.herokuapp.com/dog"
    gif = open(dogstreamer).read
    gif
  end

  def self.help
    "!dogs - show a random dog GIF"
  end
end
