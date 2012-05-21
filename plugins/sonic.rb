require 'open-uri'
require 'hpricot'

class Sonic < Linkbot::Plugin

  def self.help
    "!sonic - get a dumb random sonic gif"
  end

  def self.on_message(message, matches)
    page = rand(29)
    doc = Hpricot(open("http://dumbrunningsonic.tumblr.com/page/#{page}").read)
    imgs = doc.search("div[@class=post-content] img").map {|x| x.attributes['src']}
    imgs[rand(imgs.length)]
  end

  Linkbot::Plugin.register('sonic', self, {
    :message => {:regex => /!sonic/i, :handler => :on_message, :help => :help}
  })
end
