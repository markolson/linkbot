class Gif < Linkbot::Plugin

  def self.help
    "!gif - get a random animated gif from gif.tv"
  end

  def self.on_message(message, matches)
    url = URI.parse('http://www.gif.tv/gifs/get.php')
    res = Net::HTTP.get(url)
    "http://www.gif.tv/gifs/#{res}.gif"
  end

  Linkbot::Plugin.register('gif', self, {
    :message => {:regex => /^!gif$/i, :handler => :on_message, :help => :help}
  })
end
