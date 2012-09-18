class Cats < Linkbot::Plugin
  Linkbot::Plugin.register('cats', self,
    {
      :message => {:regex=> /^!cats$/i, :handler=> :on_message}
    }
  )

  def self.on_message(message, matches)
    reddit = "http://www.reddit.com/r/cats.json"
    catstreamer = "http://catstreamer.herokuapp.com/cats.json"
    doc = ActiveSupport::JSON.decode(open(catstreamer).read)
    url = doc["catpic"]
    #url = doc["data"]["children"][rand(doc["data"]["children"].length)]["data"]["url"]
    msg = "cats"
    msg
    url
  end

  def self.help
    "!cats = show a random cat gif"
  end
end
