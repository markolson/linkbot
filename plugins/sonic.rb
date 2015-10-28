require 'open-uri'
require 'hpricot'

class Sonic < Linkbot::Plugin

  def initialize
    register :regex => /!sonic/i
    help "!sonic - get a dumb random sonic gif"
  end

  def on_message(message, matches)
    page = rand(29)
    doc = Hpricot(open("http://dumbrunningsonic.tumblr.com/page/#{page}").read)
    imgs = doc.search("div[@class=contentwrap] img").map {|x| x.attributes['src']}
    imgs[rand(imgs.length)]
  end

end
