class Cats < Linkbot::Plugin
  Linkbot::Plugin.register('cats', self,
    {
      :message => {:regex=> /^!cats$/i, :handler=> :on_message, :help => :help}
    }
  )

  def self.on_message(message, matches)
    catstreamer = "http://catstreamer.herokuapp.com/cats.json"
    doc = ActiveSupport::JSON.decode(open(catstreamer).read)
    url = doc["catpic"]
    url
  end

  def self.help
    "!cats - show a random cat gif"
  end
end
